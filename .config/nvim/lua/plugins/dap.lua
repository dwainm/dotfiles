return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text"
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dap.adapters.php = {
			type = 'executable',
			command = 'node',
			args = { os.getenv('HOME') .. '/projects/vscode-php-debug/out/phpDebug.js' }
		}
		dap.configurations.php = {
			{
				type = 'php',
				request = 'launch',
				name = 'Listen for Xdebug',
				port = 9003
			}
		}
		dapui.setup()
		require("nvim-dap-virtual-text").setup()
		--
		-- add custom listeners to open the UI when debugging starts
		--
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Leader-based debug commands
		vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
		vim.keymap.set('n', '<Leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
			{ desc = 'Debug: Set Conditional Breakpoint' })
		vim.keymap.set('n', '<Leader>dl',
			function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
			{ desc = 'Debug: Set Log Point' })
		vim.keymap.set('n', '<Leader>dc', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
		vim.keymap.set('n', '<Leader>di', function() dap.step_into() end, { desc = 'Debug: Step Into' })
		vim.keymap.set('n', '<Leader>do', function() dap.step_over() end, { desc = 'Debug: Step Over' })
		vim.keymap.set('n', '<Leader>dO', function() dap.step_out() end, { desc = 'Debug: Step Out' })
		vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end, { desc = 'Debug: Open REPL' })
		vim.keymap.set('n', '<Leader>du', function() dap.toggle() end, { desc = 'Debug: Toggle UI' })
		vim.keymap.set('n', '<Leader>dx', function() dap.terminate() end, { desc = 'Debug: Terminate' })
		vim.keymap.set('n', '<Leader>dq', function()
			dap.terminate()
			dapui.close()
		end, { desc = 'Debug: Quit' })

		-- Create a debug mode with single key mappings
		local debug_map = function()
			local debug_wins = {}

			-- Store current buffer and window
			local buf = vim.api.nvim_get_current_buf()

			-- Create new keymap group just for debugging
			local opts = { buffer = buf, noremap = true, silent = true }

			-- Single key mappings (only active during debugging)
			vim.keymap.set('n', 'c', function() dap.continue() end, opts)
			vim.keymap.set('n', 'n', function() dap.step_over() end, opts)
			vim.keymap.set('n', 'i', function() dap.step_into() end, opts)
			vim.keymap.set('n', 'o', function() dap.step_out() end, opts)
			vim.keymap.set('n', 'b', function() dap.toggle_breakpoint() end, opts)
			vim.keymap.set('n', 'B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, opts)
			vim.keymap.set('n', 'L', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
				opts)
			vim.keymap.set('n', 'r', function() dap.repl.open() end, opts)
			vim.keymap.set('n', 'u', function() dapui.toggle() end, opts)
			vim.keymap.set('n', 'q', function()
				dap.terminate()
				dapui.close()
			end, opts)
			vim.keymap.set('n', '<Esc>', function()
				-- Clean up debug keymaps when exiting debug mode
				for _, key in ipairs({ 'c', 'n', 'i', 'o', 'b', 'B', 'L', 'r', 'u', 'q', '<Esc>' }) do
					vim.keymap.del('n', key, { buffer = buf })
				end
				-- Add Escape message
				vim.notify("Debug keys disabled", vim.log.levels.INFO)
			end, opts)

			vim.notify("Debug mode: single-key commands active", vim.log.levels.INFO)
		end

		-- Start debug mode with debugging
		vim.keymap.set('n', '<Leader>dm', debug_map, { desc = 'Debug: Enable single-key mode' })
	end
}
