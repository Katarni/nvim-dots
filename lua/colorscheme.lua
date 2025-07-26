local colorscheme = 'torchlight'

vim.o.background = "dark"

local is_color_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_color_ok then 
	vim.notify("colorscheme" .. colorscheme .. "not found")
	return 
end

