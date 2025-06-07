{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    kanshi # auto-detect plugging in monitor
    waybar # panel for sway
    dmenu # launcher bar
    font-awesome # font needed by waybar
    swaylock # lock screen
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY="wayland-1";
      DISPLAY = ":0";
    }; 
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };

  # Login / display manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # fingerprint login
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };


  # text base login manager:
  # services.greetd = {
  #   enable = true;
  #     settings = {
  #       default_session.command = ''
  #        ${pkgs.greetd.tuigreet}/bin/tuigreet \
  #          --time \
  #          --asterisks \
  #          --user-menu \
  #          --cmd sway
  #      '';
  #   };
  # };


  # environment.etc."greetd/environments".text = ''
  #   sway
  # '';

}
