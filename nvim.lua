-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Leader key
vim.g.mapleader = " "

-- Color scheme
pcall(function()
    require("tokyonight").setup({style = "night", transparent = false})
    vim.cmd([[colorscheme tokyonight]])
end)

-- Treesitter configuration
pcall(function()
    require('nvim-treesitter.configs').setup({
        highlight = {enable = true},
        indent = {enable = true}
    })
end)

-- LSP configuration with error handling
local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if lspconfig_ok then
    local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    local capabilities = cmp_ok and cmp_nvim_lsp.default_capabilities() or nil

    -- Clangd setup for C++
    lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
            "clangd", "--background-index", "--suggest-missing-includes",
            "--clang-tidy", "--header-insertion=iwyu"
        },
        on_attach = function(client, bufnr)
            -- Key mappings for LSP
            local opts = {noremap = true, silent = true, buffer = bufnr}
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>f',
                           function()
                vim.lsp.buf.format {async = true}
            end, opts)
        end
    })

    -- CMake LSP
    lspconfig.cmake.setup({capabilities = capabilities})
end

-- Completion setup
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
    cmp.setup({
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({select = true})
        }),
        sources = cmp.config.sources({
            {name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'path'}
        })
    })
end

-- Plugin configurations with error handling
pcall(
    function() require('lualine').setup({options = {theme = 'tokyonight'}}) end)

pcall(function()
    require("nvim-tree").setup({
        view = {width = 30},
        renderer = {group_empty = true},
        filters = {dotfiles = true}
    })
end)

pcall(function() require("gitsigns").setup() end)

pcall(function() require("Comment").setup() end)

pcall(function() require("nvim-autopairs").setup() end)

-- Telescope
pcall(function()
    require('telescope').setup({
        defaults = {
            file_ignore_patterns = {
                "node_modules", ".git/", "target/", "build/"
            }
        }
    })
    pcall(function() require('telescope').load_extension('fzf') end)
end)

-- Key mappings
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>',
               {desc = 'Toggle file explorer'})
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>',
               {desc = 'Find files'})
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>',
               {desc = 'Live grep'})
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>',
               {desc = 'Find buffers'})
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>',
               {desc = 'Help tags'})

-- Quick compile and run for single files
vim.keymap.set('n', '<leader>cc',
               ':!clang++ -std=c++20 -g -Wall -Wextra % -o %:r<CR>',
               {desc = 'Compile C++'})
vim.keymap
    .set('n', '<leader>cr', ':!./%:r<CR>', {desc = 'Run compiled program'})

-- LSP diagnostic navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
               {desc = 'Go to previous diagnostic'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
               {desc = 'Go to next diagnostic'})
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float,
               {desc = 'Open diagnostic float'})
