return {
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        dependencies = {
            { 'nvim-lua/plenary.nvim', branch = 'master' },
        },
        build = 'make tiktoken',
        opts = {
            -- See Configuration section for options
            model = 'gemini-3-pro-preview',
        },
    },
}
