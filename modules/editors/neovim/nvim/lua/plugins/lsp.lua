return {
	"neovim/nvim-lspconfig",
	opts = {
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
				-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
				-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
				-- prefix = "icons",
			},
			severity_sort = true,
		},
		capabilities = {},
		autoformat = true,
		-- LSP Server Settings
		servers = {
			jsonls = {},
			nil_ls = {},
			lua_ls = {
				-- mason = false, -- set to false if you don't want this server to be installed with mason
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
		},
	},
}
