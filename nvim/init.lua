vim.loader.enable()

local function check_dependency(exec)
  if vim.fn.executable(exec) == 0 then
    vim.notify(
      exec .. "is missing",
      vim.log.levels.ERROR,
      { title = "System Requirements", timeout = 10000 }
    )
  end
end

-- Behaviours
vim.opt.autocomplete = true
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.o.pumheight = 15

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.wrap = false
vim.opt.title = true
vim.opt.breakindent = true
vim.opt.scrolloff = 8

require("vim._core.ui2").enable()

-- Decrease update times
vim.opt.updatetime = 250

-- Searching
vim.opt.grepprg = "rg --vimgrep --smart-case --no-heading"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"

-- Indentation
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Appearance
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Show invisibles
vim.opt.list = true
vim.opt.listchars = {
  tab = "▷ ",
  trail = "·",
  precedes = "«",
  extends = "»",
}
-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_bufsettings = "noma nomod nobl nowrap ro nu rnu"
vim.g.netrw_list_hide = "^\\./$"

-- Spellcheck
vim.wo.spell = true
vim.bo.spelllang = "en,nb,ru"

-- Key Maps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local profile = os.getenv("NVIM_PROFILE") or "base"
vim.g.profile = profile
local profiles = {
  base = {
    ts = {
      "lua",
      "markdown",
      "markdown_inline",
      "vimdoc",
      "yaml",
      "json",
    },
    ls = {},
    tools = {},
  },
  home = {
    ts = {
      "lua",
      "markdown",
      "markdown_inline",
      "vimdoc",
      "yaml",
      "json",
      "c_sharp",
      "beancount",
      "make",
    },
    ls = {
      "lua_ls",
    },
    tools = {
      "stylua",
      "csharpier",
    },
  },
  work = {
    ts = {
      "lua",
      "markdown",
      "markdown_inline",
      "vimdoc",
      "yaml",
      "json",
      "c_sharp",
      "javascript",
      "typescript",
      "css",
      "bicep",
      "make",
    },
    ls = {
      "lua_ls",
      "eslint",
      "bicep",
      "ts_ls",
      "yamlls",
    },
    tools = {
      "stylua",
      "csharpier",
    },
  },
}

check_dependency("rg")
check_dependency("fzf")

-- Plugins
require("lazy").setup({
  {
    "cranberry-clockworks/coal.nvim",
    enabled = profile == "base",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("coal")
    end,
  },
  {
    "bluz71/vim-moonfly-colors",
    enabled = profile == "work" or profile == "home",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("moonfly")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = profiles[profile].ts,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gblame", "Gpush", "Gpull" },
    keys = {
      { "<leader>dw", "<cmd>Gwrite<cr>", desc = "[d]iff [w]rite" },
      {
        "<leader>dl",
        "<cmd>diffget //2 | diffupdate<cr>",
        desc = "Select for [d]iff from [l]eft column",
      },
      {
        "<leader>dr",
        "<cmd>diffget //3 | diffupdate<cr>",
        desc = "Select for [d]iff from [r]ight column",
      },
    },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>ec",
        function()
          require("oil").open()
        end,
        desc = "[E]xplore files around [c]urrent one",
      },
      {
        "<leader>ew",
        function()
          require("oil").open(vim.fn.getcwd())
        end,
        desc = "[E]xplore files in current [w]orking directory",
      },
    },
    lazy = false,
    opts = {
      default_file_explorer = false,
      columns = {},
      view_options = {
        show_hidden = true,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-lua/plenary.nvim",
      "cranberry-knight/telescope-compiler.nvim",
    },
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "[f]ind [f]iles",
      },
      {
        "<leader>fk",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "[f]ind [k]eys",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "[f]ind [b]uffer",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "[f]ind with [g]rep",
      },
      {
        "<leader>fc",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Fuzzy [f]ind in [c]urrent buffer",
      },
      {
        "<leader>sf",
        function()
          require("telescope.builtin").filetypes()
        end,
        desc = "[s]elect [f]iletype",
      },
      {
        "<leader>sc",
        function()
          require("telescope").extensions.compiler.compiler()
        end,
        desc = "[s]elect [c]ompiler",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").spell_suggest()
        end,
        desc = "[s]pell [s]uggests",
      },
      {
        "<leader>gb",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "[g]it [b]ranches",
      },
      {
        "<leader>gs",
        function()
          require("telescope.builtin").git_status()
        end,
        desc = "[g]it [s]tatus",
      },
      {
        "<leader>ws",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "Browse [w]orkspace [s]ymbols",
      },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim",
        },
      },
      pickers = {
        find_files = {
          previewer = false,
          disable_devicons = true,
        },
        buffers = {
          disable_devicons = true,
          previewer = false,
          mappings = {
            i = { ["<c-w>"] = "delete_buffer" },
            n = { ["<c-w>"] = "delete_buffer" },
          },
        },
        live_grep = {
          disable_devicons = true,
        },
        git_status = {
          disable_devicons = true,
        },
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        "Add to [h]arpoon list",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        "Toggle [h]arpoon list",
      },

      {
        "<leader>h1",
        function()
          require("harpoon"):list():select(1)
        end,
        "Select [h]arpoon [1]st item",
      },
      {
        "<leader>h2",
        function()
          require("harpoon"):list():select(2)
        end,
        "Select [h]arpoon [2]st item",
      },
      {
        "<leader>h3",
        function()
          require("harpoon"):list():select(3)
        end,
        "Select [h]arpoon [3]st item",
      },
      {
        "<leader>h4",
        function()
          require("harpoon"):list():select(4)
        end,
        "Select [h]arpoon [4]st item",
      },
      {
        "<C-S-]>",
        function()
          require("harpoon"):list():next()
        end,
        "Select previous [h]arpoon item",
      },
      {
        "<C-S-[>",
        function()
          require("harpoon"):list():prev()
        end,
        "Select next [h]arpoon item",
      },
    },
    config = function()
      local harpoon = require("harpoon")

      harpoon:setup()
    end,
  },
  {
    "danymat/neogen",
    enabled = profile == "home" or profile == "work",
    keys = {
      {
        "<leader>ng",
        function()
          require("neogen").generate()
        end,
        desc = "[N]eogen [g]enarate comment",
      },
    },
    opts = {
      languages = {
        cs = {
          template = { annotation_convention = "xmldoc" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = profiles[profile].ls,
      automatic_enable = true,
    },
    dependencies = {
      "mason-org/mason.nvim",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = profiles[profile].tools,
    },
  },
  {
    "seblyng/roslyn.nvim",
    enabled = profile == "home" or profile == "work",
    ft = { "cs", "razor" },
    opts = {},
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    enabled = profile == "home" or profile == "work",
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      ui.setup({
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "→",
        },
        controls = {
          enabled = false,
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        ui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        ui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        ui.close({})
      end

      dap.adapters.coreclr = {
        -- To debug on mac, you need to use custom compiled debugger for arm64:
        -- https://github.com/Cliffback/netcoredbg-macOS-arm64.nvim/releases
        command = vim.fn.expand(
          vim.fs.joinpath(vim.fn.stdpath("data"), "netcoredbg", "netcoredbg")
        ),
        type = "executable",
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.exepath("dotnet")
          end,
          args = {
            "run",
            "--project",
            "Laerdal.Web/Laerdal.Web.csproj",
            "-c",
            "Laerdal.Local",
          },
        },
      }
    end,
    keys = {
      {
        "gdb",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle [d]ebug [b]reakpoint",
      },
      {
        "gdB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Toggle [d]ebug [b]reakpoint wiht condition",
      },
      {
        "gdc",
        function()
          require("dap").continue()
        end,
        desc = "[d]ebug [c]ontinue",
      },
      {
        "gdC",
        function()
          require("dap").run_last()
        end,
        desc = "[d]ebug run last",
      },
      {
        "gdt",
        function()
          require("dap").terminate()
        end,
        desc = "[d]ebug [t]erminate",
      },
      {
        "gds",
        function()
          require("dap").step_over()
        end,
        desc = "[d]ebug [s]tep over",
      },
      {
        "gdi",
        function()
          require("dap").step_into()
        end,
        desc = "[d]ebug step [i]nto",
      },
      {
        "gdo",
        function()
          require("dap").step_out()
        end,
        desc = "[d]ebug step [o]ut",
      },
      {
        "gdr",
        function()
          require("dap").repl.open()
        end,
        desc = "[d]ebug open [r]epl",
      },
      {
        "gdu",
        function()
          require("dapui").toggle()
        end,
        desc = "[d]ebug toggle [u]i",
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = profile == "work",
    lazy = false,
    opts = {
      suggestion = {
        keymap = {
          accept = "<C-0>",
          next = "<C-e>",
          dismiss = "<C-a>",
        },
      },
      panel = { enabled = false },
    },
  },
  {
    "ThePrimeagen/99",
    enabled = profile == "work",
    config = function()
      local _99 = require("99")
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup({
        -- model = "github-copilot/gpt-5.3-codex",
        model = "lmstudio/qwen/qwen3.6-35b-a3b",
        logger = {
          level = _99.DEBUG,
          path = "/tmp/99/" .. basename .. ".99.debug",
          print_on_error = true,
        },
        tmp_dir = "./.tmp",
        completion = {
          custom_rules = {
            "~/.config/nvim/skills/",
          },
          files = {},
          source = "native",
        },
        md_files = {
          "AGENT.md",
        },
      })
      vim.keymap.set("v", "<leader>9v", function()
        _99.visual()
      end)
      vim.keymap.set("n", "<leader>9x", function()
        _99.stop_all_requests()
      end)
      vim.keymap.set("n", "<leader>9s", function()
        _99.search()
      end)
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    },
    enabled = profile == "home" or profile == "work",
    opts = function()
      return {
        adapters = {
          require("neotest-dotnet")({
            dap = {
              args = { justMyCode = false },
              adapter_name = "coreclr",
            },
          }),
        },
      }
    end,
    keys = {
      {
        "<leader>tu",
        function()
          local nt = require("neotest")
          nt.summary.toggle()
          nt.output_panel.toggle()
        end,
        desc = "[t]oggle [t]est view",
      },
      {
        "<leader>tr",
        function()
          local nt = require("neotest")
          nt.output_panel.open()
          nt.run.run()
        end,
        "[t]est [r]un current method",
      },
      {
        "<leader>td",
        function()
          local nt = require("neotest")
          nt.output_panel.close()
          nt.run.run({ strategy = "dap" })
        end,
        "[t]est [d]ebug current method",
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 80,
      },
    },
  },
}, {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock-" .. profile .. ".json",
})

vim.filetype.add({
  extension = {
    bicep = "bicep",
    razor = "razor",
    cshtml = "razor",
    bu = "yaml",
  },
})

-- Native LSP Server Configs (Neovim 0.12)
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      format = { enable = false },
      diagnostics = { globals = { "vim" } },
      telemetry = { enable = false },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

vim.lsp.config("beancount", {
  cmd = { "beancount-language-server", "--stdio" },
  filetypes = { "beancount" },
  root_markers = { "main.beancount", ".git" },
  init_options = {
    journal_file = "main.beancount",
  },
})

vim.lsp.config("eslint", {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "eslint.config.mjs", ".git" },
})

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
})

vim.lsp.config("bicep", {
  cmd = { "bicep-lsp" },
  filetypes = { "bicep" },
  root_markers = { "bicepconfig.json", ".git" },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
})

vim.diagnostic.config({ virtual_text = true })

-- LSP keymaps
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format()
end, { desc = "[l]SP [f]ormat" })

vim.keymap.set("n", "<leader>ll", function()
  vim.diagnostic.setloclist()
end, { desc = "Put [l]sp diagnostics to [l]ocation list" })

-- Key Maps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Generic
vim.keymap.set("n", "<leader>tsc", function()
  if vim.wo.spell then
    vim.wo.spell = false
    vim.notify("Disable spellcheck")
    return
  end

  vim.wo.spell = true
  vim.notify("Enable spellcheck")
end, { desc = "[t]oggle [s]pell [c]heck" })

vim.keymap.set("n", "<leader>thw", function()
  local width = vim.call("input", "Enter new hard wrap text width: ")
  vim.opt.wrap = false
  vim.opt.textwidth = tonumber(width)
  vim.opt.colorcolumn = tostring(width)
end, { desc = "[t]oggle [h]ard [w]rap" })

vim.api.nvim_create_user_command("EnableSoftWrap", function()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = true
  vim.wo.showbreak = "↪ "
  vim.opt.textwidth = tonumber(0)
  vim.opt.colorcolumn = tostring(0)
end, { nargs = 0, force = true })

vim.api.nvim_create_user_command("DisableSoftWrap", function()
  vim.wo.linebreak = false
  vim.wo.breakindent = false
  vim.wo.showbreak = ""
end, { nargs = 0, force = true })

vim.keymap.set("n", "<leader>tsw", function()
  vim.wo.wrap = not vim.wo.wrap
  if vim.wo.wrap then
    vim.cmd("EnableSoftWrap")
    vim.notify("Enable text soft wrap")
  else
    vim.cmd("DisableSoftWrap")
    vim.notify("Disable soft wrap")
  end
end, { desc = "[t]oggle [s]oft [w]rap" })

-- Override default LSP formatting for C# to use csharpier
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    -- Format entire buffer
    vim.keymap.set(
      "n",
      "<leader>lf",
      "<cmd>!dotnet csharpier format \"%\"<CR>",
      {
        buffer = true,
        desc = "Override [L]SP for [F]ormat file with csharpier",
      }
    )
  end,
})

-- Split the lines
vim.keymap.set("n", "<leader>sl", function()
  local char = vim.fn.input("Split by: ")
  if char ~= "" then
    local pattern = vim.fn.escape(char, "\\/.*$^~[]") -- escape special regex chars
    vim.cmd("s/" .. pattern .. "/\\r/g")
  end
end, { desc = "Split current line by input chars" })

-- Jump between errors
vim.keymap.set("n", "]e", function()
  vim.diagnostic.jump({
    count = 1,
    severity = vim.diagnostic.severity.ERROR,
    wrap = true,
  })
end, { desc = "Next diagnostic error" })

vim.keymap.set("n", "[e", function()
  vim.diagnostic.jump({
    count = -1,
    severity = vim.diagnostic.severity.ERROR,
    wrap = true,
  })
end, { desc = "Next diagnostic error" })

-- Jump between warnings
vim.keymap.set("n", "]w", function()
  vim.diagnostic.jump({
    count = 1,
    severity = vim.diagnostic.severity.WARNING,
    wrap = true,
  })
end, { desc = "Next diagnostic error" })

vim.keymap.set("n", "[w", function()
  vim.diagnostic.jump({
    count = -1,
    severity = vim.diagnostic.severity.WARNING,
    wrap = true,
  })
end, { desc = "Next diagnostic error" })

vim.keymap.set("n", "fu", function()
  vim.cmd("Undotree")
end, { desc = "[f]ind entry in native [u]ndo tree" })

-- View git conflict markers
vim.keymap.set("n", "<leader>lc", function()
  local ok, _ = pcall(vim.cmd, "vimgrep /^[<=>]\\{7\\}/ %")

  if ok then
    vim.cmd("copen") -- Open the list if matches found
  else
    vim.notify("No conflicts found", vim.log.levels.INFO)
  end
end, { desc = "[l]ist [c]onflict markers" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Enable native completion for this buffer
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(
        true,
        args.data.client_id,
        args.buf,
        { autotrigger = true }
      )
    end
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

if profile == "home" or profile == "work" then
  require("dotnet-tools").setup()
end
