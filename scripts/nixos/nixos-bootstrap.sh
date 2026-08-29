#!/usr/bin/env bash

# nix-shell -p parted -p e2fsprogs --run zsh

# usage: <function> <img>

parse_args() {
  while :; do
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
  parted "$IMG" -- mkpart primary fat32 1MiB 300MiB
  parted "$IMG" -- set 1 boot on
  parted "$IMG" -- mkpart primary ext4 300MiB 100%

  prep-loop "$IMG"
  sudo sh -c "
    mkfs.vfat -F32 -n boot \"${LOOP}p1\";
    mkfs.ext4 -L nixos \"${LOOP}p2\"
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
  PASS= # TODO
}

edit-config() {
  IMG="$1"
  mount-image "$IMG"
  (cd "$BASE/mnt/etc/nixos/"; vi "configuration.nix")
  umount-image "$IMG"
}

parse_args "$@"

