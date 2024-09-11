return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  branch = "regexp", -- This is the regexp branch, use this for the new version
  config = function()
    require("venv-selector").setup({
      anaconda_base_path = "~/miniconda3",
      anaconda_envs_path = "~/miniconda3/envs",
      stay_on_this_version = true,
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    })
  end,
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>" },
  },
}
