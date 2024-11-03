{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/Users/zach";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
