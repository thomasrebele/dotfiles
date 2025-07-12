# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sway.nix
      ./security.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["apm=power_off" "reboot=acpi"];
  boot.kernelModules = ["acpi_call" 
	"vfio" "vfio_iommu_type1" "vfio_pci" "kvmgt" "i915" "mdev"];

  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  networking.hostName = "t470s"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # fix broken eth connection after waking up from suspend
  systemd.services.networkmanager-resume = {
    description = "Restart NetworkManager after suspend";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '"+
        "${pkgs.coreutils}/bin/sleep 8; "+
        "${pkgs.systemd}/bin/systemctl restart NetworkManager'";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "neo";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  services.xserver.xkb.variant = "neo";
  #services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    extraConfig = {
      pipewire."99-silent-bell.conf" = {
        "context.properties" = {
          "module.x11.bell" = false;
	};
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      # command line tools
      zsh
      tree
      ripgrep
      jq
      mawk
      zip
      unzip
      p7zip
      inotify-tools # inotifywait
      # python for dir-shortener
      python3
      # container config generate script
      python312Packages.pyyaml

      xfce.thunar
      xarchiver
      thunderbird
      vlc
      gimp
      evince

      gitFull
      git-cola
      meld

      remmina
      wl-clipboard # wayland-clipboard interaction
      copyq # clipboard manager
      wdisplays # screen config GUI
      guestfs-tools # provides virt-sparsify
#      python
      alacritty # opengl terminal emulator

      podman # containerization
      zenity # easy dialogs (e.g., for calle)

      # mount usb
      udisks
      # udiskie # automount

      fwknop # connection to VPS
      wget

      anki-bin
      zoom-us
      libreoffice

      android-tools
      scrcpy # connect with phone
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "zoom"
  ];

  # mount usb
  services.devmon.enable = true;
  services.gvfs.enable = true;
  #services.udisks2.enable = true; # automount

  # virt-manager configuration
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["tr"];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
    kvmgt.enable = true;
    kvmgt.vgpus = {
      "i915-GVTg_V5_4" = { uuid = [ "0457a510-9e19-4657-b695-8b3d9ef4b8b5" ]; };
    };
  };
  services.spice-vdagentd.enable = true;


  virtualisation.virtualbox.host.enable = true;
  users.extraUsers.tr.extraGroups = [ "libvirtd" "kvm" ];
  users.extraGroups.vboxusers.members = [ "tr" ];

  # zsh
  programs.zsh.enable = true;

  # successor of vim, supports clipboard on wayland
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        set backupcopy=yes
        set number
      '';
    };
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
    acpitool # print battery stats
    tmux # terminal multiplexing
    linuxPackages.acpi_call # required for special battery settings (tpacpi-bat)

    usbutils
    pciutils

    #virtmanager # added during nixos IGVT-g configuration

    ddrescue # better dd for backups

    glib # required by xdg-open
  ];

  environment.shellAliases = {
    vi = "nvim";
  };

  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    dejavu_fonts
    # nixos 25.05 or later: nerd-fonts.droid-sans-mono
    # (nerdfonts.override { fonts = [ "DroidSansMono " ]; })
    # droid-sans-mono 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # List services that you want to enable:

  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70;
      
      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 60; # bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 70; # above it stops charging

      START_CHARGE_THRESH_BAT1 = 60; # bellow it starts to charge
      STOP_CHARGE_THRESH_BAT1 = 70; # above it stops charging
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

  # Locate command
  services.locate.enable = true;

  services.dbus.packages = with pkgs; [
    xfce.xfconf # necessary to save settings in thunar, xfce4-terminal
  ];

  # Printing
  nixpkgs.config.allowUnfree = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprintBin pkgs.canon-cups-ufr2 ];
  services.avahi = { # auto-detect printers
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # enable LAN nic even when on battery
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="enp0s31f6", ATTR{power/control}="on"
  '';
}

