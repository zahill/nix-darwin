{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/Users/zach";

  home.file = {
    ".zshrc".source = dotfiles/.zshrc;
    ".config/nvim".source = dotfiles/nvim;
    ".config/aerospace".source = dotfiles/aerospace;
    ".config/neofetch".source = dotfiles/neofetch;
    ".config/raycast".source = dotfiles/raycast;
    ".config/kitty".source = dotfiles/kitty;
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
