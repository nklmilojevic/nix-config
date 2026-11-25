{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) kache;
  logDir = "${config.home.homeDirectory}/Library/Logs/kache";
in
{
  home.packages = [ kache ];

  # Declarative replacement for `kache init`, which edits files Home Manager owns
  # and links shims to a store path that breaks after garbage collection.
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${kache}/bin/kache"

    [env]
    HOST_CC = "kache cc"
    HOST_CXX = "kache c++"
    CC_KNOWN_WRAPPER_CUSTOM = "kache"
  '';

  # launchd does not create the parent directory of StandardOutPath.
  home.activation.kacheLogDir = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    run mkdir -p ${logDir}
  '';

  # Mirrors the plist `kache daemon install` writes (src/service.rs).
  launchd.agents.kache = {
    enable = true;
    config = {
      Label = "ninja.kunobi.kache";
      ProgramArguments = [
        "${kache}/bin/kache"
        "daemon"
        "run"
      ];
      AssociatedBundleIdentifiers = [ "ninja.kunobi.kache" ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      StandardOutPath = "${logDir}/out.log";
      StandardErrorPath = "${logDir}/err.log";
      EnvironmentVariables.KACHE_LOG = "kache=info";
      ThrottleInterval = 5;
    };
  };
}
