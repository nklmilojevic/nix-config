{...}: let
  nixpkgsConfig = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };
in {
  nixpkgs.config = nixpkgsConfig;
}
