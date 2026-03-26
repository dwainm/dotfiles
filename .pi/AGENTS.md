
---

## Recent Work Log - 2025-03-26: Pi Tau Mux Complete Implementation

**Goal:** Set up Tau server/client for Pi coding agent with Tailscale support, filtering old sessions, adding connection notifications, and publishing changes.

### Completed
- ✅ Configured yadm tracking for pi-tau-mux extension
- ✅ Published pi-tau-mux@1.0.9 (client extension) with Tailscale-aware notifications
- ✅ Published pi-tau-mux-server@1.0.8 (standalone server) with session filtering
- ✅ Fixed session status thresholds (15min active, 24hr recent instead of 3 days)
- ✅ Added /api/instances endpoint for UI live indicators
- ✅ Fixed API query parameter handling for UI filters (?status=active)
- ✅ Committed harness changes to yadm dotfiles repo

### Key Features Implemented
1. **Tailscale Auto-Detection** - Automatically detects 100.x.x.x IPs via CLI or network interfaces
2. **Connection Notifications** - Shows "Connected to Tau mux server at Tailscale" with actual URL
3. **Server URL Forwarding** - Server sends public URLs (local, Tailscale, MagicDNS) to clients
4. **Session Filtering** - API supports ?status=active to show only currently active sessions
5. **Better Defaults** - Client defaults to port 3010, matches server out-of-box

### Packages Published
- **pi-tau-mux@1.0.9** - https://www.npmjs.com/package/pi-tau-mux
- **pi-tau-mux-server@1.0.8** - https://www.npmjs.com/package/pi-tau-mux-server

### Repositories
- Client: https://github.com/dwainm/pi-tau-mux
- Server: https://github.com/dwainm/pi-tau-mux-server

### Usage
```bash
# Terminal 1
pi-tau-mux-server

# Terminal 2
pi  # Auto-connects and shows Tailscale URL
```

### Test URLs
- UI: http://100.102.17.57:3010/
- API: http://100.102.17.57:3010/api/sessions?status=active
- Live: http://100.102.17.57:3010/api/instances
