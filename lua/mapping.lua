local keymap = vim.keymap
local opts = {
    noremap = true,
    silent = true
}

-- Normal --

keymap.set("n", "<Up>", "<nop>", opts) 
keymap.set("n", "<Left>", "<nop>", opts) 
keymap.set("n", "<Right>", "<nop>", opts) 
keymap.set("n", "<Down>", "<nop>", opts) 

keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)


