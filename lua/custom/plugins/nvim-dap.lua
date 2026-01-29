-- lua/custom/plugins/nvim-dap.lua
return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'mfussenegger/nvim-dap-python',
        {
            'rcarriga/nvim-dap-ui',
            dependencies = { 'nvim-neotest/nvim-nio' },
            config = function()
                local dapui = require 'dapui'
                dapui.setup {
                    layouts = {
                        {
                            elements = {
                                { id = 'scopes', size = 0.35 },
                                { id = 'breakpoints', size = 0.15 },
                                { id = 'stacks', size = 0.25 },
                                { id = 'watches', size = 0.25 },
                            },
                            size = 40,
                            position = 'left',
                        },
                        {
                            elements = {
                                { id = 'repl', size = 0.5 },
                                { id = 'console', size = 0.5 },
                            },
                            size = 10,
                            position = 'bottom',
                        },
                    },
                    floating = { border = 'rounded' },
                }
                local dap = require 'dap'
                dap.listeners.after.event_initialized['dapui_config'] = function()
                    dapui.open {}
                end
                dap.listeners.before.event_terminated['dapui_config'] = function()
                    dapui.close {}
                end
                dap.listeners.before.event_exited['dapui_config'] = function()
                    dapui.close {}
                end
            end,
        },
        'theHamsta/nvim-dap-virtual-text',
    },

    config = function()
        local dap = require 'dap'

        -- [[ 关键修改：直接计算路径，不依赖 Mason 注册表 API ]]
        -- Mason 的标准安装根目录通常是 ~/.local/share/nvim/mason (Linux/Mac)
        local mason_path = vim.fn.stdpath 'data' .. '/mason/packages'

        -- 1. C++ 配置 (codelldb)
        -- 直接指向二进制文件，只要你 Mason 装了，它就在这
        local codelldb_path = mason_path .. '/codelldb/extension/adapter/codelldb'

        dap.adapters.codelldb = {
            type = 'executable',
            command = codelldb_path,
            name = 'codelldb',
        }

        dap.configurations.cpp = {
            {
                name = 'Launch file',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
            },
        }
        dap.configurations.c = dap.configurations.cpp

        -- 2. Python 配置 (debugpy)
        -- 直接指向 venv 里的 python 解释器
        local debugpy_python_path = mason_path .. '/debugpy/venv/bin/python'

        -- 这里的 setup 会自动处理 adapter 和 configuration
        require('dap-python').setup(debugpy_python_path)

        -- 3. UI 图标
        vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'Error' })
        vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DiagnosticInfo', linehl = 'CursorLine', numhl = 'CursorLine' })
    end,

    keys = {
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
            '<space>db',
            function()
                require('dap').toggle_breakpoint()
            end,
            desc = 'DAP Toggle Breakpoint',
        },
        {
            '<space>du',
            function()
                require('dapui').toggle()
            end,
            desc = 'DAP Toggle UI',
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
        -- Python 专用
        {
            '<space>dPm',
            function()
                require('dap-python').test_method()
            end,
            desc = 'DAP Python Test Method',
            ft = 'python',
        },
    },
}
