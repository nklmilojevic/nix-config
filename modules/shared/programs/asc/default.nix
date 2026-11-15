# asc: App Store Connect CLI (TestFlight uploads, metadata, signing). The module
# also sets ASC_TELEMETRY_DISABLED=1, since upstream telemetry is on by default.
{ inputs, ... }:
{
  imports = [ inputs.asc.homeManagerModules.default ];

  programs.asc.enable = true;
}
