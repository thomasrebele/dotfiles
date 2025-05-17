{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    niri # niri window manager
  ];

  # enable niri window manager
  programs.niri = {
    enable = true;
  };

  xdg.portal.wlr.enable = lib.mkForce true;
  programs.xwayland.enable = lib.mkForce true;
}
