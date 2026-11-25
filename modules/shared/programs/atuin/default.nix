{ config, lib, ... }:
let
  socketDir = "${config.xdg.dataHome}/atuin";
in
{
  catppuccin = {
    fish = {
      enable = true;
    };
  };

  # `atuin daemon start` does not create the parent directory of a custom
  # `socket_path` (fresh installs store data under `~/.atuin`), causing the
  # daemon to exit 1 and every fish preexec hook to stall ~2s.
  home.activation.atuinSocketDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p -m 700 ${lib.escapeShellArg socketDir}
  '';

  programs.atuin = {
    enable = true;
    enableFishIntegration = false;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      dialect = "uk";
      inline_height = "40";
      show_help = "false";
      sync_address = "https://atuin.nikola.wtf";
      auto_sync = true;
      sync_frequency = "1m";
      search_mode = "daemon-fuzzy";
      history_filter = [
        "sk-(proj-|ant-)?[A-Za-z0-9_-]{20,}"
        "(?i)authorization:\\s*bearer\\s+[A-Za-z0-9._~+/=-]{16,}"
        "(?i)[A-Z_]*(TOKEN|API_KEY|SECRET|PASSWORD)[A-Z_]*=[^\\s$(]{8,}"
        "(?i)--password[= ][^\\s$(]\\S*"
      ];
      sync = {
        records = true;
      };
      daemon = {
        enabled = true;
        autostart = true;
        # Default is $TMPDIR/atuin-$UID/atuin.sock, so shells with a different
        # TMPDIR miss the running daemon and every preexec hook stalls ~4s.
        socket_path = "${socketDir}/atuin.sock";
      };
      threads = {
        capture = true;
      };
      pty_proxy = {
        enabled = true;
      };
      output = {
        enabled = true;
      };
      ai = {
        enabled = true;
        endpoint = "https://atuin-ai.nikola.wtf";
        opening = {
          send_last_command = true;
        };
      };
    };
  };
}
