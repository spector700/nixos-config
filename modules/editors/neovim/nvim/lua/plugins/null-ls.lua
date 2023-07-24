return {
	"jose-elias-alvarez/null-ls.nvim",
	opts = function()
		local nls = require("null-ls")
		return {
			root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
			sources = {
				nls.builtins.formatting.prettier,
				nls.builtins.formatting.stylua,
				nls.builtins.formatting.beautysh,
				nls.builtins.formatting.nixpkgs_fmt,
				-- nls.builtins.diagnostics.flake8,
			},
		}
	end,
}
