#!/usr/bin/env bash

# nix-shell -p parted -p e2fsprogs --run zsh
# TODO: var for e2label

# usage: <function> <img>

set -euxo pipefail

parse_args() {
  while [ "$#" -gt 0 ]; do
    case $1 in 
      -?*)
	printf "Unknown option: %s\n" "$1" >&2
	exit
	;;

      *)
	cmd="$1"
	shift
	$cmd "$@"
	break
	;;
    esac
    shift
  done
}

create-image() {
  if [ -f "$1" ]; then
    printf "image %s already exist, abandon\n" "$1"
    return
  fi

  IMG="$1"
  truncate -s 5G "$IMG"
  parted "$IMG" -- mklabel msdos
  parted "$IMG" -- mkpart primary fat32 1MiB 512MiB
  parted "$IMG" -- set 1 boot on
  parted "$IMG" -- mkpart primary ext4 512MiB 100%

  prep-loop "$IMG"
  sudo sh -c "
    mkfs.vfat -F32 -n boot \"${LOOP}p1\";
    mkfs.ext4 -L nixos \"${LOOP}p2\";
    e2label \"{LOOP}p2\" nixos-usb-sys
    "

}

prep-loop() {
  IMG="$1"
  LOOP=$(losetup -a | grep "\($IMG\)" | sed 's/:.*//' | head -n 1)
  if [ "$LOOP" = "" ]; then
    udisksctl loop-setup -f "$IMG"
    # alternatively: sudo losetup -fP "$IMG"
  fi
  LOOP=$(losetup -a | grep "\($IMG\)" | sed 's/:.*//' | head -n 1)
  
  printf "loop device: %s\n" "$LOOP"
}

mount-image() {
  IMG="$1"
  BASE="$(dirname "$IMG")"

  prep-loop "$IMG"
  mkdir -p "$BASE/mnt"
  sudo sh -c "
    mount \"${LOOP}p2\" \"$BASE/mnt\";
    mkdir -p \"$BASE/mnt/boot\";
    mount \"${LOOP}p1\" \"$BASE/mnt/boot\"
    "
}

umount-image() {
  IMG="$1"
  BASE="$(dirname "$IMG")"

  sudo sh -c "
    umount \"$BASE/mnt/boot\";
    umount \"$BASE/mnt\";
    "
}

copy-config() {
  IMG="$1"
  mount-image "$IMG"


  if [ -f "$BASE/mnt/etc/nixos/configuration.nix" ]; then
    echo "config file exists, do not overwrite"
    return
  fi

cat > "$BASE/mnt/etc/nixos/hardware-configuration.nix" <<EOF
# modify configuration.nix instead
{ config, lib, pkgs, modulesPath, ... }:
 
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
 
  fileSystems."/" = { device = "/dev/disk/by-label/nixos-usb-sys"; fsType = "ext4"; };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];   
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
EOF

cat > "$BASE/mnt/etc/nixos/configuration.nix" <<EOF
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # use grub for hybrid BIOS+UEFI boot
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/loop0";
    #useOSProber = false;
  };

  # network
  networking.hostName = "nixos-usb";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_DK.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "neo";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # strip down
  services.logrotate.enable = false;
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = true;
    nixos.enable = false;
  };

  users.users.tr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # enable ‘sudo’ 
    packages = with pkgs; [ tree ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    ripgrep
    wget
  ];

  environment.defaultPackages = [];
  system.copySystemConfiguration = true;

  # DO NOT CHANGE THE stateVersion!
  system.stateVersion = "26.05"; # Did you read the comment?
}
EOF

  umount-image "$IMG"
}

edit-config() {
  IMG="$1"
  mount-image "$IMG"
  (cd "$BASE/mnt/etc/nixos/"; vi "configuration.nix")
  umount-image "$IMG"
}

bootstrap() {
  PASS= # TODO
  IMG="$1"
  create-image "$IMG"
  copy-config "$IMG"
  cd "$BASE"
  nixos-install --root "$(realpath mnt/)"/
}

parse_args "$@"

