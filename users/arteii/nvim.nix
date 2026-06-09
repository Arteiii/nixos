{ ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    globals.mapleader = " ";

    colorschemes.catppuccin.enable = true;

    opts = {
      number = true;
      relativenumber = true;

      tabstop = 8;
      softtabstop = 8;
      shiftwidth = 8;
      expandtab = false;

      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      clipboard = "unnamedplus";
      confirm = true;

      shell = "zsh";
    };

    plugins = {
      web-devicons.enable = true;

      lualine.enable = true;
      neo-tree = {
        enable = true;
        settings = {
          filesystem = {
            filtered_items = {
              visible = true;
            };
          };
        };
      };
      nvim-autopairs.enable = true;

      harpoon = {
        enable = true;
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
        };
      };

      treesitter = {
        enable = true;
        settings.ensure_installed = [
          "rust"
          "regex"
          "toml"
          "yaml"
          "nix"
          "lua"
          "c"
          "cpp"
          "make"
          "markdown"
          "markdown_inline"
          "javascript"
          "typescript"
          "tsx"
          "css"
          "html"
          "json"
          "diff"
        ];

        settings = {
          highlight.enable = true;
          indent.enable = true;
          rainbow = {
            enable = true;
            query = "rainbow-parens";
            strategy = "global";
          };
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          # Ctrl + t toggles the terminal open
          open_mapping = "[[<C-t>]]";
          direction = "horizontal";
          start_in_insert = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          clangd = {
            enable = true;
            autostart = true;
          };
          ts_ls.enable = true;
          marksman.enable = true;
          jsonls.enable = true;
          cssls.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "K" = "hover";
          "gr" = "references";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
      };

      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };
    };

    extraConfigLua = ''
      vim.filetype.add({
        extension = {
          ixx = "cpp",
          mdx = "markdown",
        },
      })
    '';

    keymaps = [
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
      }

      # toggle the visibility of neotree (space e)
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options = {
          desc = "Toggle Neo-tree visibility";
        };
      }

      # focus neo tree side bar (space f)
      {
        mode = "n";
        key = "<leader>f";
        action = ":Neotree focus<CR>";
        options = {
          desc = "Focus Neo-tree";
        };
      }

      # Quick-navigation keys out of the terminal window
      {
        mode = "t";
        key = "<C-h>";
        action = "<C-\\><C-n><C-w>h";
      }
      {
        mode = "t";
        key = "<C-j>";
        action = "<C-\\><C-n><C-w>j";
      }
      {
        mode = "t";
        key = "<C-k>";
        action = "<C-\\><C-n><C-w>k";
      }
      {
        mode = "t";
        key = "<C-l>";
        action = "<C-\\><C-n><C-w>l";
      }
    ];
  };
}
