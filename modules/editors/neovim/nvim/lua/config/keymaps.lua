-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
	local keys = require("lazy.core.handler").handlers.keys
	---@cast keys LazyKeysHandler
	-- do not create the keymap if a lazy keys handler exists
	if not keys.active[keys.parse({ lhs, mode = mode }).id] then
		opts = opts or {}
		opts.silent = opts.silent ~= false
		if opts.remap and not vim.g.vscode then
			opts.remap = nil
		end
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

map("i", "<C-a>", function()
	vim.cmd("norm! ggVG")
	print("Selected all lines")
end, { remap = false, desc = "select all lines in buffer" })

-- Move Lines
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Keep register if pasting over word
map("v", "p", '"_dP')

-- Move windows
map("n", "<C-Up>", "<C-w>k", { desc = "Move Window Up" })
map("n", "<C-Down>", "<C-w>j", { desc = "Move Window Down" })
map("n", "<C-Right>", "<C-w>l", { desc = "Move Window Right" })
map("n", "<C-Left>", "<C-w>h", { desc = "Move Window Left" })

-- buffers
if Util.has("bufferline.nvim") then
	map("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
	map("n", "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
	map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
	map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
end

if vim.g.vscode then
	print("⚡connected to neovim! 😎")

	map("n", "gr", function()
		local go2Referces = "call VSCodeNotify('editor.action.referenceSearch.trigger')"
		vim.cmd(go2Referces)
	end, { noremap = true, desc = "peek references inside vs code" })

	map("n", "<leader>e", function()
		local openFileExplorer = "call VSCodeNotify('workbench.files.action.focusFilesExplorer')"
		vim.cmd(openFileExplorer)
	end, { noremap = true, desc = "focus to file explorer" })

	map("n", "<leader>gg", function()
		local openGitSourceControl = "call VSCodeNotify('workbench.view.scm')"
		vim.cmd(openGitSourceControl)
	end, { noremap = true, desc = "open git source controll" })

	map("n", "<leader>ca", function()
		local codeAction4QuickFix = "call VSCodeNotify('editor.action.quickFix')"
		vim.cmd(codeAction4QuickFix)
	end, { noremap = true, desc = "open quick fix in vs code" })
else
end
