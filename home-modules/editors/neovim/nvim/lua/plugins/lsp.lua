return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			nixd = {},
			ruff_lsp = {
				mason = false,
			},
			lua_ls = {
				mason = false,
			},
		},
	},
}
