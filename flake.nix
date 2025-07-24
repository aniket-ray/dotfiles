{
  description = "Aniket's personal nix-darwin system flake";

  inputs = {
    # Core Nixpkgs & nix-darwin
    nixpkgs.url = "github:NixOS/nixpkgs/25.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-Homebrew support
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Home-Manager for per-user config
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, nix-darwin, nix-homebrew, home-manager, ... }:
    let
      # quote & rename hyphenated inputs
      homebrewCore = inputs."homebrew-core";
      homebrewCask = inputs."homebrew-cask";

      # your system-wide nix-darwin module
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = "nix-command flakes";

        # system packages
        environment.systemPackages = with pkgs; [
          awscli2
          pandoc
          pinentry_mac
          rustup
          docker
          oh-my-zsh
          neovim
          python313
          git
          clang_20
          clang-tools
          htop
          tmux
          tree
          wget
          direnv
          uv
        ];

        # fonts
        fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

        # macOS defaults
        system.defaults = {
          dock.autohide = false;
          dock.orientation = "left";
          dock.launchanim = false;
          dock.tilesize = 40;
          dock.show-process-indicators = true;
          dock.minimize-to-application = true;

          finder.FXPreferredViewStyle = "icnv";
          finder.ShowPathbar = true;
          finder._FXShowPosixPathInTitle = true;
          finder.NewWindowTarget = "Home";

          iCal."first day of week" = "Monday";
          iCal."TimeZone support enabled" = true;
          iCal.CalendarSidebarShown = true;

          controlcenter.BatteryShowPercentage = true;
          controlcenter.Bluetooth = true;
          controlcenter.NowPlaying = false;
          controlcenter.Sound = true;
          controlcenter.FocusModes = true;

        };

        # Homebrew
        homebrew = {
          enable = true;
          brews = [ "texlive" "virtualenv" ];
          casks = [
            "wacom-tablet"
            "pgadmin4"
            "amazon-chime"
            "cursor"
            "brave-browser"
            "protonvpn"
            "firefox"
            "ghostty"
            "rectangle"
            "clion"
            "pycharm"
            "gpg-suite"
            "signal"
            "whatsapp"
            "microsoft-office"
            "microsoft-teams"
            "proton-mail"
            "proton-drive"
            "bitwarden"
            "google-chrome"
            "yubico-yubikey-manager"
            "yubico-authenticator"
            "visual-studio-code"
            "zoom"
            "logitech-g-hub"
          ];
          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
        };

        # darwin versioning & primary user
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
        system.primaryUser = "aniket";
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in {
      darwinConfigurations."Anikets-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration

          # nix-homebrew module + your brew taps
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew.enable = true;
            nix-homebrew.enableRosetta = true;
            nix-homebrew.user = "aniket";
            nix-homebrew.taps = {
              "homebrew/homebrew-core" = homebrewCore;
              "homebrew/homebrew-cask" = homebrewCask;
            };
            nix-homebrew.mutableTaps = false;
          }

          # Home-Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            users.users.aniket.home = "/Users/aniket";
            home-manager.users.aniket = import ./home.nix;
          }
        ];
      };
    };
}
