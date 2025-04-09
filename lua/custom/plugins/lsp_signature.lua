return {
  {
    'ray-x/lsp_signature.nvim',
    event = 'VeryLazy',
    opts = {
      hint_enable = true, -- 禁用虚拟提示（可选配置）
      hi_parameter = 'LspSignatureActiveParameter', -- 高亮参数
    },
    config = function(_, opts)
      require('lsp_signature').setup(opts)
    end,
  },
}
