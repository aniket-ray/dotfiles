{ pkgs, ... }: {
  home.username = "aniket";
  home.homeDirectory = "/Users/aniket";
  home.stateVersion = "25.05";

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Aniket Ray";
    userEmail = "iam@aniketray.me";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "true";
      commit.gpgsign = true;
      tag.gpgsign = true;
      user.signingkey = "FCE22664BBA7C0DE";
    };
  };

  programs.gpg = {
    enable = true;
    # Additional configuration
    mutableKeys = true; # Allow importing keys manually
    mutableTrust = true; # Allow modifying trust settings
  };

  # Enable GPG agent
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;

    defaultCacheTtl = 3600; # 1 hour
    defaultCacheTtlSsh = 3600; # 1 hour for SSH keys
    maxCacheTtl = 86400; # 24 hours max
  };

  # ZSH with Oh-my-zsh
  programs.zsh = {
    enable = true;
    zplug = {
      enable = true;
      plugins = [
        # Theme
        {
          name = "romkatv/powerlevel10k";
          tags = [ "as:theme" "depth:1" ];
        }

        # Common Aliases
        {
          name = "plugins/common-aliases";
          tags = [ "from:oh-my-zsh" ];
        }

        # System Tools
        {
          name = "plugins/sudo";
          tags = [ "from:oh-my-zsh" ];
        }
        {
          name = "plugins/colored-man-pages";
          tags = [ "from:oh-my-zsh" ];
        }

        # Additional useful plugins (not from oh-my-zsh)
        { name = "zsh-users/zsh-autosuggestions"; }
        {
          name = "zsh-users/zsh-syntax-highlighting";
          tags = [ "defer:2" ];
        }
        { name = "zsh-users/zsh-completions"; }
      ];
    };
    initContent = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "~/.cache/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "~/.cache/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load Powerlevel10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  # Neovim configuration for C++
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # C++ development tools
    extraPackages = with pkgs; [
      # Language servers
      clang-tools # includes clangd LSP server
      cmake-language-server

      # Debugger
      lldb

      # Build tools
      cmake
      ninja
      gcc
      clang

      # Formatters and linters
      clang-tools # includes clang-format
      cppcheck

      # Other utilities
      ripgrep
      fd
      tree-sitter

      # For debugging support
      gdb
    ];

    plugins = with pkgs.vimPlugins; [
      # Essential plugins - these are well-maintained and stable
      nvim-treesitter.withAllGrammars
      telescope-nvim
      telescope-fzf-native-nvim

      # LSP support
      nvim-lspconfig

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      # File management
      nvim-tree-lua
      nvim-web-devicons # Required for nvim-tree

      # UI enhancements
      lualine-nvim

      # Git integration
      gitsigns-nvim

      # Color schemes
      tokyonight-nvim

      # Utility plugins
      comment-nvim
      nvim-autopairs
    ];

    extraLuaConfig = builtins.readFile ./nvim.lua;
  };

  # User packages
  home.packages = with pkgs; [ git tmux htop tree wget ];

  home.file.".p10k.zsh" = { source = ./p10k.zsh; };
}
