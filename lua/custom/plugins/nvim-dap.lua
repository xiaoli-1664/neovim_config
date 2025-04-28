-- lua/custom/plugins/nvim-dap.lua
return {
  -- Main DAP plugin
  'mfussenegger/nvim-dap',
  dependencies = {
    -- UI for DAP
    {
      'rcarriga/nvim-dap-ui',
      -- Ensure UI plugin is configured AFTER the main DAP plugin
      dependencies = {
        'nvim-neotest/nvim-nio',
      },
      config = function()
        local dapui = require 'dapui'
        dapui.setup {
          -- Layout configuration (customize as needed)
          layouts = {
            {
              elements = {
                { id = 'scopes', size = 0.35 },
                { id = 'breakpoints', size = 0.15 },
                { id = 'stacks', size = 0.25 },
                { id = 'watches', size = 0.25 },
              },
              size = 40, -- Controls the initial size of the left sidebar
              position = 'left',
            },
            {
              elements = {
                { id = 'repl', size = 0.5 },
                { id = 'console', size = 0.5 },
              },
              size = 10, -- Controls the initial size of the bottom panel
              position = 'bottom',
            },
          },
          floating = {
            max_height = nil, -- use plenary popup border that is not fixed size
            max_width = nil, -- use plenary popup border that is not fixed size
            border = 'rounded', -- Adjust border style if needed
            mappings = {
              close = { 'q', '<Esc>' },
            },
          },
          controls = { enabled = true }, -- Show controls (play, step, etc.) in DAP UI
          render = { -- Configure rendering options if desired
            max_type_length = nil, -- adjust width for types in scopes/watches etc.
          },
        }

        -- Automatically open/close DAP UI when debugging starts/stops
        local dap = require 'dap'
        dap.listeners.after.event_initialized['dapui_config'] = function()
          vim.schedule(function()
            dapui.open {}
          end)
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
          vim.schedule(function()
            dapui.close {}
          end)
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
          vim.schedule(function()
            dapui.close {}
          end)
        end
      end,
    },

    -- Optional: Virtual text for DAP info
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        require('nvim-dap-virtual-text').setup {}
      end,
    },

    -- Optional: Integration with nvim-notify
    -- {
    --  "rcarriga/nvim-notify",
    --  opts = {
    --      -- Configuration for nvim-notify if needed
    --  },
    -- },
  },
  -- Main configuration for nvim-dap
  config = function()
    local dap = require 'dap'
    local mason_registry = require 'mason-registry' -- Required to find adapter path

    -- Setup C++ debugging using codelldb installed via Mason
    local codelldb_path = mason_registry.get_package('codelldb'):get_install_path() .. '/extension/adapter/codelldb'

    dap.adapters.codelldb = {
      type = 'executable',
      command = codelldb_path,
      name = 'codelldb',
      -- Optional: environment variables or other adapter-specific settings
      -- env = { VAR = "value" }
    }

    -- Define the launch configuration for C++ projects
    dap.configurations.cpp = {
      {
        name = 'Launch file (codelldb)',
        type = 'codelldb', -- Must match the adapter name/key defined above
        request = 'launch',
        program = function()
          -- Ask for the executable path dynamically
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}', -- Run program in the project root
        stopOnEntry = false, -- Don't stop at the program entry point automatically
        runInTerminal = false, -- Set to true if your program needs a terminal (e.g., for curses); otherwise, false uses internal console
        -- args = function() -- Example for dynamic arguments
        --   local args_str = vim.fn.input("Program arguments: ")
        --   return vim.split(args_str, " ")
        -- end,
        -- Example static arguments:
        -- args = { "arg1", "arg2" },
      },
      -- Add other configurations if needed (e.g., attaching to a running process)
      -- {
      --   name = "Attach (codelldb)",
      --   type = "codelldb",
      --   request = "attach",
      --   processId = require('dap.utils').pick_process, -- Helper to select a process
      --   cwd = "${workspaceFolder}",
      -- },
    }

    -- Set language alias if needed (usually cpp maps correctly, but doesn't hurt)
    dap.configurations.c = dap.configurations.cpp

    -- Setup signs for breakpoints (optional, customize symbols/highlight)
    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'Error', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DiagnosticInfo', linehl = 'CursorLine', numhl = 'CursorLine' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '❓', texthl = 'WarningMsg', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '💡', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })

    print 'sign configured successfully!'
  end,
  -- Keymaps for DAP - customize the leader key and specific bindings as needed
  keys = {
    -- General DAP Bindings
    {
      '<space>dc',
      function()
        require('dap').continue()
      end,
      desc = 'DAP Continue',
    },
    {
      '<space>dj',
      function()
        require('dap').step_over()
      end,
      desc = 'DAP Step Over',
    },
    {
      '<space>dk',
      function()
        require('dap').step_into()
      end,
      desc = 'DAP Step Into',
    },
    {
      '<space>do',
      function()
        require('dap').step_out()
      end,
      desc = 'DAP Step Out',
    },
    {
      '<space>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'DAP Terminate',
    },
    {
      '<space>dr',
      function()
        require('dap').repl.open()
      end,
      desc = 'DAP Open REPL',
    },
    {
      '<space>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'DAP Run Last',
    },

    -- Breakpoints
    {
      '<space>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'DAP Toggle Breakpoint',
    },
    {
      '<space>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'DAP Set Conditional Breakpoint',
    },
    {
      '<space>dp',
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end,
      desc = 'DAP Set Logpoint',
    },

    -- DAP UI Bindings
    {
      '<space>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'DAP Toggle UI',
    },
    {
      '<space>de',
      function()
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'DAP UI Eval',
    },

    -- Optional: Bindings for specific UI elements if needed
    -- { "<leader>dsc", function() require("dapui").elements.scopes.toggle() end, desc = "DAP UI Toggle Scopes" },
    -- { "<leader>dst", function() require("dapui").elements.stacks.toggle() end, desc = "DAP UI Toggle Stacks" },
  },
}
