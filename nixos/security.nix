{ config, lib, pkgs, ... }:
{
	environment.defaultPackages = lib.mkForce [];

	security.auditd.enable = true;
	security.audit.enable = true;
	security.audit.rules = [
		"-a exit,always -F arch=b64 -S execve"
	];

	services.openssh = {
		#settings.KbdInteractiveAuthentication = false;
		extraConfig = ''
			AllowTcpForwarding = yes
			X11Forwarding no
			AllowAgentForwarding no
			AllowStreamLocalForwarding no
			AuthenticationMethods publickey
		'';
	};

# TODO: tre does not yet work, "no specified mount point for device" error
#	fileSystems."/".options = [ "noexec" ];
#	fileSystems."/etc/nixos".options = [ "noexec" ];
#	fileSystems."/srv".options = [ "noexec" ];
#	fileSystems."/var/log".options = [ "noexec" ];
}
