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
