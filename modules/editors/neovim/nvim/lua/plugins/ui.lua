return {
	-- border around hover ui
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			opts.presets.lsp_doc_border = true
		end,
	},
}
