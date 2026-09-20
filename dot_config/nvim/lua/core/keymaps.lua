local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 常用
map({ "n", "v" }, "<Space>", "<Nop>", opts)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)
map("i", "jj", "<Esc>", opts)
map("n", "q", "<cmd>:q<CR>", opts)
map("n", "<C-i>", "<cmd>edit<CR>", opts)

-- 标签页
map("n", "<leader>tn", "<cmd>tabnew<CR>", opts)
map("n", "<leader>tc", "<cmd>tabclose<CR>", opts)

-- 分屏
map("n", "sv", "<cmd>vsplit<CR>", opts)
map("n", "sh", "<cmd>split<CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<leader>=", "<C-w>=", opts)

-- 终端
map("n", "<leader>t", "<cmd>botright 15split | terminal<CR>i", opts)
-- 自动保存
map("n", "<leader>ts", "<cmd>AutoSaveToggle<CR>", opts)

map("t", "jj", [[<C-\><C-n>]], opts)
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)

-- 诊断
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, opts)
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<leader>q", vim.diagnostic.setloclist, opts)
