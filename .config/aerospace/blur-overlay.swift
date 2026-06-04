#!/usr/bin/env swift
// Blur Overlay - standalone macOS blur overlay
// Compile: swiftc blur-overlay.swift -o blur-overlay
// Usage: ./blur-overlay on|off|toggle

import Cocoa
import Carbon.HIToolbox

// Private API to get CGWindowID from AXUIElement
@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(_ element: AXUIElement, _ windowID: UnsafeMutablePointer<CGWindowID>) -> AXError

// MARK: - State file for persistence
let stateFile = "/tmp/blur-overlay.pid"

func isRunning() -> pid_t? {
    guard let pidStr = try? String(contentsOfFile: stateFile, encoding: .utf8),
          let pid = pid_t(pidStr.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        return nil
    }
    // Check if process is actually running
    if kill(pid, 0) == 0 {
        return pid
    }
    try? FileManager.default.removeItem(atPath: stateFile)
    return nil
}

func saveState(_ pid: pid_t) {
    try? "\(pid)".write(toFile: stateFile, atomically: true, encoding: .utf8)
}

func clearState() {
    try? FileManager.default.removeItem(atPath: stateFile)
}

// MARK: - Configuration
struct BlurConfig {
    static var material: Int = 0          // 0=dark, 1=light, 2=ultra dark
    static var dimOpacity: Double = 0.3   // 0-1, additional darkening
}

// MARK: - Overlay Window
class BlurOverlayWindow: NSWindow {
    var effectView: NSVisualEffectView!
    var dimLayer: CALayer!
    
    // Prevent window from ever taking focus
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        self.level = .floating
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        
        // Create visual effect view with strong blur
        effectView = NSVisualEffectView(frame: screen.frame)
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        
        // Use dark material for heavy blur effect
        switch BlurConfig.material {
        case 1:
            effectView.material = .light
        case 2:
            effectView.material = .ultraDark
        default:
            effectView.material = .dark
        }
        
        // Add extra dim layer on top
        dimLayer = CALayer()
        dimLayer.backgroundColor = NSColor.black.withAlphaComponent(BlurConfig.dimOpacity).cgColor
        dimLayer.frame = effectView.bounds
        dimLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        effectView.layer?.addSublayer(dimLayer)
        
        self.contentView = effectView
    }
    
    func updateDim(_ opacity: Double) {
        dimLayer.backgroundColor = NSColor.black.withAlphaComponent(opacity).cgColor
    }
}

// MARK: - Overlay Manager
class OverlayManager: NSObject, NSApplicationDelegate {
    var overlays: [BlurOverlayWindow] = []
    var windowTracker: AXObserver?
    var focusedApp: NSRunningApplication?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check accessibility
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            print("Please grant Accessibility permissions in System Settings")
        }
        
        // Create overlays for each screen
        for screen in NSScreen.screens {
            let overlay = BlurOverlayWindow(screen: screen)
            overlay.orderFront(nil)
            overlays.append(overlay)
        }
        
        // Track focused window
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        
        // Initial update
        if let app = NSWorkspace.shared.frontmostApplication {
            updateCutout(for: app)
        }
        
        // Save PID
        saveState(ProcessInfo.processInfo.processIdentifier)
        
        // Poll for window changes (simpler than AX observers)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let app = NSWorkspace.shared.frontmostApplication {
                self?.updateCutout(for: app)
            }
        }
    }
    
    @objc func appActivated(_ notification: Notification) {
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            updateCutout(for: app)
        }
    }
    
    func updateCutout(for app: NSRunningApplication) {
        guard let pid = app.processIdentifier as pid_t? else { return }
        
        let appRef = AXUIElementCreateApplication(pid)
        var focusedWindow: CFTypeRef?
        AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        guard let window = focusedWindow else {
            // No focused window - show full blur
            for overlay in overlays {
                overlay.contentView?.layer?.mask = nil
            }
            return
        }
        
        // Get the CGWindowID of the focused window to order our overlay below it
        var windowID: CGWindowID = 0
        _AXUIElementGetWindow(window as! AXUIElement, &windowID)
        
        // Order overlays just below the focused window
        if windowID != 0 {
            for overlay in overlays {
                overlay.order(.below, relativeTo: Int(windowID))
            }
        }
        
        // Get window position and size
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        AXUIElementCopyAttributeValue(window as! AXUIElement, kAXPositionAttribute as CFString, &positionValue)
        AXUIElementCopyAttributeValue(window as! AXUIElement, kAXSizeAttribute as CFString, &sizeValue)
        
        var position = CGPoint.zero
        var size = CGSize.zero
        
        if let posRef = positionValue {
            AXValueGetValue(posRef as! AXValue, .cgPoint, &position)
        }
        if let sizeRef = sizeValue {
            AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)
        }
        
        let windowFrame = NSRect(origin: position, size: size)
        
        // Update each overlay with a cutout for the focused window
        for overlay in overlays {
            let screenFrame = overlay.frame
            
            // Convert window frame to screen coordinates
            let cutoutRect = NSRect(
                x: windowFrame.origin.x - screenFrame.origin.x,
                y: screenFrame.height - (windowFrame.origin.y - screenFrame.origin.y) - windowFrame.height,
                width: windowFrame.width,
                height: windowFrame.height
            )
            
            // Create mask layer with cutout
            let maskLayer = CAShapeLayer()
            let path = NSBezierPath(rect: overlay.contentView!.bounds)
            
            // Only cut out if window is on this screen
            if screenFrame.intersects(windowFrame) {
                let cutout = NSBezierPath(roundedRect: cutoutRect, xRadius: 10, yRadius: 10)
                path.append(cutout.reversedPath())
            }
            
            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd
            
            overlay.contentView?.wantsLayer = true
            overlay.contentView?.layer?.mask = maskLayer
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clearState()
    }
}

// MARK: - NSBezierPath extension for CGPath
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            case .cubicCurveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .quadraticCurveTo: path.addQuadCurve(to: points[1], control: points[0])
            @unknown default: break
            }
        }
        return path
    }
    
    func reversedPath() -> NSBezierPath {
        let reversed = NSBezierPath()
        for i in stride(from: elementCount - 1, through: 0, by: -1) {
            var points = [CGPoint](repeating: .zero, count: 3)
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: reversed.move(to: points[0])
            case .lineTo: reversed.line(to: points[0])
            case .curveTo: reversed.curve(to: points[0], controlPoint1: points[2], controlPoint2: points[1])
            case .closePath: reversed.close()
            default: break
            }
        }
        return reversed
    }
}

// MARK: - Main
let args = CommandLine.arguments

func printUsage() {
    print("""
    Usage: blur-overlay <command> [options]
    
    Commands:
      on      Start blur overlay
      off     Stop blur overlay
      toggle  Toggle blur overlay
      status  Check if running
    
    Options (with 'on'):
      --material <0-2>  0=dark, 1=light, 2=ultradark (default: 0)
      --dim <0-100>     Additional dim percentage (default: 30)
    
    Examples:
      blur-overlay on --material 2 --dim 50
      blur-overlay toggle
    """)
}

// Parse options
func parseOptions() {
    var i = 2
    while i < args.count {
        switch args[i] {
        case "--material":
            if i + 1 < args.count, let val = Int(args[i + 1]) {
                BlurConfig.material = min(2, max(0, val))
                i += 1
            }
        case "--dim":
            if i + 1 < args.count, let val = Double(args[i + 1]) {
                BlurConfig.dimOpacity = min(100, max(0, val)) / 100.0
                i += 1
            }
        default:
            break
        }
        i += 1
    }
}

guard args.count >= 2 else {
    printUsage()
    exit(1)
}

let command = args[1].lowercased()

switch command {
case "on":
    if let pid = isRunning() {
        print("Already running (PID \(pid))")
        exit(0)
    }
    parseOptions()
    let materialNames = ["dark", "light", "ultradark"]
    print("Material: \(materialNames[BlurConfig.material]), Dim: \(Int(BlurConfig.dimOpacity * 100))%")
    // Fork and run overlay
    let app = NSApplication.shared
    let delegate = OverlayManager()
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // No dock icon
    app.run()
    
case "off":
    if let pid = isRunning() {
        kill(pid, SIGTERM)
        clearState()
        print("Stopped blur overlay")
    } else {
        print("Not running")
    }
    
case "toggle":
    if let pid = isRunning() {
        kill(pid, SIGTERM)
        clearState()
        print("Blur OFF")
    } else {
        // Need to exec ourselves in background
        let task = Process()
        task.executableURL = URL(fileURLWithPath: args[0])
        task.arguments = ["on"]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        try? task.run()
        print("Blur ON")
    }
    
case "status":
    if let pid = isRunning() {
        print("Running (PID \(pid))")
    } else {
        print("Not running")
    }
    
default:
    printUsage()
    exit(1)
}
