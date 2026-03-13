if vim.g.vscode then
  require("init-vscode")
  return
end
-- Plugins
local Plug = vim.fn["plug#"]
vim.call("plug#begin")
Plug("christoomey/vim-tmux-navigator")
Plug("neovim/nvim-lspconfig")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-lualine/lualine.nvim")
Plug("nvim-telescope/telescope.nvim", { tag = "*" })
Plug("nvim-telescope/telescope-fzf-native.nvim", {
  ["do"] = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
})
Plug("nvim-treesitter/nvim-treesitter")
Plug("nickpwhite/vim-polyglot")
Plug("stevearc/conform.nvim")
Plug("tpope/vim-commentary")
Plug("tpope/vim-fugitive")
Plug("tpope/vim-rails")
Plug("tpope/vim-repeat")
Plug("tpope/vim-rhubarb")
Plug("tpope/vim-surround")
vim.call("plug#end")

-- Options
vim.g.mapleader = " "

vim.cmd.colorscheme("retrobox")

local system_theme =
  vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout:gsub("%s+", "")

if system_theme == "Dark" then
  vim.opt.background = "dark"
else
  vim.opt.background = "light"
end
vim.cmd.highlight({ "link", "Whitespace", "ColorColumn" })

vim.opt.clipboard:append("unnamedplus")
vim.opt.colorcolumn = "100"
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.matchpairs:append("<:>")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 7
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.undofile = true

vim.opt.wrap = false

-- Autocmds
local autocmds = vim.api.nvim_create_augroup("init.lua", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file to last location",
  command = 'silent! normal! g`"zv',
  group = autocmds,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  desc = "Reload init.lua",
  pattern = { vim.env.MYVIMRC },
  command = "luafile $MYVIMRC",
  group = autocmds,
})

-- Mappings
vim.keymap.set(
  "n",
  "<Leader>vimrc",
  "<cmd>tabe $MYVIMRC<cr>",
  { desc = "Open init.lua in a new tab" }
)
vim.keymap.set(
  "n",
  "<Leader>yf",
  '<cmd>let @+ = expand("%:t:r")<cr>',
  { desc = "Yank the current filename to the clipboard" }
)
vim.keymap.set(
  "n",
  "<Leader>yp",
  '<cmd>let @+ = expand("%")<cr>',
  { desc = "Yank the current path to the clipboard" }
)

-- Plugin Config
-- conform.nvim
require("conform").setup({
  formatters = {
    stylua = {
      prepend_args = { "--config-path", vim.env.HOME .. "/.config/nvim/stylua.toml" },
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    ruby = { "rubyfmt" },
    sql = { "pg_format" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { lsp_format = "first" }
  end,
})

-- telescope.nvim
require("telescope").setup()
vim.keymap.set(
  "n",
  "<C-p>",
  "<cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files<cr>",
  { desc = "Find files" }
)
vim.keymap.set("n", "<C-b>", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<C-f>", "<cmd>Telescope live_grep<cr>", { desc = "Grep the codebase" })

-- lualine.nvim
local function trunc(trunc_width, trunc_len)
  return function(str)
    local win_width = vim.api.nvim_win_get_width(0)
    if trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
      return str:sub(1, trunc_len) .. "…"
    end
    return str
  end
end

require("lualine").setup({
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "branch",
        fmt = trunc(200, 25),
      },
      "diff",
      "diagnostics",
    },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "encoding", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- lsp
local function append_node_options(opts)
  local current = vim.env.NODE_OPTIONS or ""
  if current == "" then
    return opts
  end

  for opt in opts:gmatch("%S+") do
    if not current:find(opt, 1, true) then
      current = current .. " " .. opt
    end
  end

  return current
end

local node_lsp_env = {
  NODE_OPTIONS = append_node_options("--max-old-space-size=8192 --no-warnings=ExperimentalWarning"),
}

vim.lsp.config("ts_ls", {
  cmd_env = node_lsp_env,
})

vim.lsp.config("eslint", {
  root_markers = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    "package.json",
  },
  single_file_support = false,
  cmd_env = node_lsp_env,
  settings = {
    run = "onSave",
    workingDirectory = { mode = "auto" },
  },
  flags = {
    debounce_text_changes = 500,
  },
})

vim.lsp.enable("kotlin_language_server")
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("ts_ls")
vim.lsp.enable("eslint")
vim.lsp.enable("sourcekit")

local augroup = vim.api.nvim_create_augroup("lsp", { clear = true })
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set("n", "<space>d", function()
      vim.diagnostic.open_float({
        scope = "cursor",
        focusable = true,
        close_events = {
          "CursorMoved",
          "CursorMovedI",
          "BufHidden",
          "InsertCharPre",
          "WinLeave",
        },
      })
    end)
  end,
})
