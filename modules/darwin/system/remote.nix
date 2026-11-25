{
  lib,
  pkgs,
  user,
  hostName,
  isRemote,
  ...
}:
let
  authorizedKeys = pkgs.writeText "authorized-keys-${user}" ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrYywYsK/kocVOa48LjaOR2X10g7lwsB1PtkyBJX800 id_ed25519
    sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBAm/ce3XSBKs/qyZh3Kbm1dIBgQ9MW3sTtk4+xgIEOIEl8fhRTQYrOgeZ07mqHeLzNATAcS3/6Xu8wrkoqUuEmsAAAAEc3NoOg== daedalus-enclave
  '';
in
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
  # Declarative keys live in /etc/ssh/authorized_keys.d/%u so ~/.ssh/authorized_keys
  # remains writable for ad-hoc keys (e.g. Thurm iPhone device keys).
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      PermitRootLogin no
      AllowStreamLocalForwarding yes
      AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
    '';
  };

  # Install as a real root:wheel 0644 file (not an environment.etc symlink into
  # /nix/store, which is 1775 group-writable and rejected by sshd StrictModes).
  system.activationScripts.openssh.text = lib.mkAfter ''
    install -d -m 0755 -o root -g wheel /etc/ssh/authorized_keys.d
    install -m 0644 -o root -g wheel ${authorizedKeys} /etc/ssh/authorized_keys.d/${user}
  '';

  # Native macOS Screen Sharing (supports Apple Silicon High Performance mode
  # with virtual displays from daedalus via Screen Sharing.app over LAN/Tailscale).
  system.activationScripts.launchd.text = lib.mkAfter ''
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';

  # System-wide tailscaled LaunchDaemon so the host rejoins the tailnet at
  # boot (e.g. after `fdesetup authrestart`), before any GUI login.
  services.tailscale.enable = true;

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
  # SSH pubkey auth + Tailscale ACLs are the perimeter for this host.
  security.sudo.extraConfig = ''
    ${user} ALL=(ALL) NOPASSWD: ALL
  '';
}
