{ config, inputs, ... }:
{
  programs.nixvim = {
    enable = true;

    # Build plugins from our nixpkgs instead of nixvim's own pin
    nixpkgs.source = inputs.nixpkgs;

    viAlias = true;
    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;

      expandtab = true;
      tabstop = 3;
      shiftwidth = 3;
      softtabstop = 3;
      smartindent = true;
      autoindent = true;

      incsearch = true;
      hlsearch = true;

      backup = false;
      swapfile = false;
      undofile = true;
      undodir = "${config.home.homeDirectory}/.local/share/nvim/undodir";
      autoread = true;

      updatetime = 50;
      scrolloff = 10;
      colorcolumn = "80";

      encoding = "utf-8";
      fileencoding = "utf-8";

      guicursor = "a:blinkon0";

      backspace = "indent,eol,start";

      clipboard = "unnamedplus";
    };

    keymaps = [
      {
        mode = "n";
        key = "<Up>";
        action = "<cmd>echo 'No up for you bitch!'<CR>";
        options.noremap = true;
      }
      {
        mode = "n";
        key = "<Down>";
        action = "<cmd>echo 'No down for you bitch!'<CR>";
        options.noremap = true;
      }
      {
        mode = "n";
        key = "<Left>";
        action = "<cmd>echo 'No left for you bitch!'<CR>";
        options.noremap = true;
      }
      {
        mode = "n";
        key = "<Right>";
        action = "<cmd>echo 'No right for you bitch!'<CR>";
        options.noremap = true;
      }

      {
        mode = "n";
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options.desc = "Toggle file tree";
      }

      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live grep";
      }

      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "Show hover documentation";
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
        options.desc = "Show references";
      }

      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>bdelete<CR>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>X";
        action = "<cmd>BufferLineCloseOthers<CR>";
        options.desc = "Close other buffers";
      }

      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show line diagnostics";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
        options.desc = "Open diagnostic list";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "Previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "Next diagnostic";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "Find diagnostics";
      }

      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
        options.desc = "Toggle comment line";
      }
      {
        mode = "v";
        key = "<leader>/";
        action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
        options.desc = "Toggle comment selection";
      }
    ];

    colorschemes.onedark.enable = true;

    autoGroups = {
      filetype_indent = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = ["FileType"];
        pattern = ["nix"];
        group = "filetype_indent";
        callback = {
          __raw = ''
            function()
              vim.opt_local.tabstop = 2
              vim.opt_local.shiftwidth = 2
              vim.opt_local.softtabstop = 2
            end
          '';
        };
      }
      {
        event = ["FileType"];
        pattern = ["yaml" "yml" "json"];
        group = "filetype_indent";
        callback = {
          __raw = ''
            function()
              vim.opt_local.tabstop = 2
              vim.opt_local.shiftwidth = 2
              vim.opt_local.softtabstop = 2
            end
          '';
        };
      }
    ];

    plugins = {
      web-devicons.enable = true;

      nvim-tree = {
        enable = true;

        settings = {
          hijack_cursor = true;
          update_focused_file.enable = true;

          view = {
            width = 30;
            side = "left";
          };

          renderer = {
            group_empty = true;
            highlight_git = true;
            icons.glyphs = {
              default = "";
              symlink = "";
              folder = {
                arrow_open = "";
                arrow_closed = "";
                default = "";
                open = "";
                empty = "";
                empty_open = "";
                symlink = "";
                symlink_open = "";
              };
            };
          };
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          ruff.enable = true;
          lua_ls.enable = true;
          zls = {
            enable = true;
            settings = {
              enable_inlay_hints = true;
              inlay_hints_show_builtin = true;
              inlay_hints_exclude_single_argument = true;
              inlay_hints_hide_redundant_param_names = false;
              inlay_hints_hide_redundant_param_names_last_token = false;
            };
          };
          clangd.enable = true;
          wgsl_analyzer.enable = true;
          vtsls.enable = true;  # JavaScript/TypeScript
          html.enable = true;
        };

        inlayHints = true;
      };

      bufferline = {
        enable = true;
        settings = {
          options = {
            mode = "buffers";
            numbers = "none";
            close_command = "bdelete! %d";
            right_mouse_command = "bdelete! %d";
            left_mouse_command = "buffer %d";
            middle_mouse_command = null;
            indicator = {
              style = "icon";
              icon = "▎";
            };
            buffer_close_icon = "󰅖";
            modified_icon = "●";
            close_icon = "";
            left_trunc_marker = "";
            right_trunc_marker = "";
            diagnostics = "nvim_lsp";
            offsets = [
              {
                filetype = "NvimTree";
                text = "File Explorer";
                text_align = "left";
                separator = true;
              }
            ];
            show_buffer_close_icons = true;
            show_close_icon = true;
            separator_style = "thin";
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet = {
            expand = { __raw = "function(args) require('luasnip').lsp_expand(args.body) end"; };
          };

          mapping = {
            __raw = ''
              {
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    fallback()
                  end
                end, {'i', 's'}),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  else
                    fallback()
                  end
                end, {'i', 's'}),
              }
            '';
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      luasnip.enable = true;

      telescope.enable = true;

      #lualine = {
      #  enable = true;
      #  settings.options.theme = "onedark";
      #};

      gitsigns.enable = true;

      nvim-autopairs.enable = true;

      comment.enable = true;

      which-key.enable = true;
    };

    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2d3748" })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })


      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    '';
  };
}
