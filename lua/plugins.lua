local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" if not (vim.uv or vim.loop).fs_stat(lazypath) then vim.fn.system({ "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "hrsh7th/cmp-nvim-lsp", lazy = true},
    { "hrsh7th/cmp-path", lazy = true},
    { "hrsh7th/cmp-buffer", lazy = true},
    { "hrsh7th/cmp-omni", lazy = true},
    { "hrsh7th/cmp-cmdline", lazy = true},
    { "quangnguyen30192/cmp-nvim-ultisnips", lazy = true},
    {
        "hrsh7th/nvim-cmp",
        name = "nvim-cmp",
        event = "VeryLazy",
        config = function()
            require("config.nvim-cmp")
        end
    },
    
	"rebelot/kanagawa.nvim",
	{
		"skylarmb/torchlight.nvim",
		opts = { contrats = medium }
	},
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        event = "VeryLazy",
        opts = {},
        init = function()
            vim.o.foldcolumn = "1" -- '0' is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
        config = function()
            require("config.nvim-ufo")
        end
    },
    {
        "daschw/leaf.nvim",
        opts = { contrast = medium }
    },
    {
        "echasnovski/mini.icons",
        version = false,
        config = function()
            require("mini.icons").mock_nvim_web_devicons()
            require("mini.icons").tweak_lsp_kind()
        end,
        lazy = true
    },
    { 
        "nvim-lualine/lualine.nvim",
        event = "BufRead",
        config = function()
            require("config.lualine")
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    {
        "neovim/nvim-lspconfig"
    },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    "mason-org/mason-lspconfig.nvim"
})
