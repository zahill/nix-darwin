{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, nikitabobko, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
      # Allow installing unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile.
      environment.systemPackages = [
          pkgs.mkalias
          pkgs.neovim
          pkgs.tmux
          pkgs.kitty
          pkgs.neofetch
          pkgs.zinit
          pkgs.starship
          pkgs.fzf
          pkgs.zoxide
          pkgs.eza
          pkgs.sketchybar
          pkgs.raycast
          pkgs.wget
          pkgs.ripgrep
          pkgs.ruby
          pkgs.tree-sitter
      ];

      fonts.packages = [
        pkgs.fira-code-nerdfont
      ];

      users.users.zach.home = "/Users/zach";
      nix.configureBuildUsers = true;

      homebrew = {
        enable = true;
        casks = [
          "hammerspoon"
          "brave-browser"
          "wireshark"
          "nikitabobko/tap/aerospace"
        ];
        masApps = {};
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Copy the applications instead of creating aliases
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      system.defaults = {
          dock.autohide = true;
          dock.magnification = true;
          dock.show-recents = false;
          dock.persistent-apps = [
            "/System/Applications/Launchpad.app"
            "${pkgs.kitty}/Applications/kitty.app"
            "/Applications/Brave Browser.app"
            "/System/Applications/Mail.app"
            "/System/Applications/Calendar.app"
            "/System/Applications/Messages.app"
            "/System/Applications/Music.app"
          ];
          dock.persistent-others = [];
          finder.FXPreferredViewStyle = "clmv";
          finder.AppleShowAllExtensions = true;
          NSGlobalDomain.AppleICUForce24HourTime = true;
          NSGlobalDomain.AppleInterfaceStyle = "Dark";
          NSGlobalDomain.KeyRepeat = 2;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Zachs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "zach";
            autoMigrate = true;
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zach = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Zachs-MacBook-Pro".pkgs;
  };
}
