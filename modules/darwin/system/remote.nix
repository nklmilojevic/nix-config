{
  lib,
  user,
  hostName,
  isRemote,
  ...
}:
lib.mkIf isRemote {
  # Set all three macOS hostnames so `.justfile` (`scutil --get ComputerName`)
  # and `darwin-rebuild --flake .` resolve `darwinConfigurations.<hostName>`.
  networking = {
    inherit hostName;
    localHostName = hostName;
    computerName = hostName;
  };

  # Remote Login (SSH) for Thurm remote workspaces and management.
  # Key-only auth; AllowStreamLocalForwarding is required for thurmd sockets.
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      PermitRootLogin no
      AllowStreamLocalForwarding yes
    '';
  };

  # Declarative SSH keys via nix-darwin's native AuthorizedKeysCommand
  # (/etc/ssh/nix_authorized_keys.d/%u), keeping ~/.ssh/authorized_keys writable.
  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrYywYsK/kocVOa48LjaOR2X10g7lwsB1PtkyBJX800 id_ed25519"
    "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBAm/ce3XSBKs/qyZh3Kbm1dIBgQ9MW3sTtk4+xgIEOIEl8fhRTQYrOgeZ07mqHeLzNATAcS3/6Xu8wrkoqUuEmsAAAAEc3NoOg== daedalus-enclave"
  ];

  # Native macOS Screen Sharing (supports Apple Silicon High Performance mode
  # with virtual displays from daedalus via Screen Sharing.app over LAN/Thurm's tailnet).
  system.activationScripts.launchd.text = lib.mkAfter ''
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';

  # Keep a remote workstation awake and recover cleanly from power loss.
  # Preventing sleep also keeps Thurm tunnels open and sefko's cache warm.
  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
  };

  system.activationScripts.power.text = lib.mkAfter ''
    pmset -a sleep 0 disksleep 0 womp 1 tcpkeepalive 1
  '';

  # Touch ID does not work over SSH, and Thurm disables SSH agent forwarding.
  # SSH pubkey auth is the perimeter for this host.
  security.sudo.extraConfig = ''
    ${user} ALL=(ALL) NOPASSWD: ALL
  '';
}
