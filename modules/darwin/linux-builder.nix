{ lib, ... }:
{
  # Linux builder VM so this Mac can build Linux derivations
  # (needed for devenv containers, docker/OCI image builds, NixOS closures).
  #
  # First activation must use the stock config — the default VM image is
  # substituted from cache.nixos.org. Customizing `nix.linux-builder.config`
  # rebuilds the image, which itself requires a working Linux builder, so
  # only uncomment the tuning below after the builder is up once.
  nix.linux-builder = {
    enable = true;
    # config = {
    #   virtualisation = {
    #     cores = 6;
    #     darwin-builder = {
    #       diskSize = 40 * 1024; # MiB
    #       memorySize = 8 * 1024; # MiB
    #     };
    #   };
    # };
  };

  # On-demand only — the VM does not start at boot and is not kept alive:
  #   start: sudo launchctl kickstart system/org.nixos.linux-builder
  #   stop:  sudo launchctl kill SIGTERM system/org.nixos.linux-builder
  launchd.daemons.linux-builder.serviceConfig = {
    RunAtLoad = lib.mkForce false;
    KeepAlive = lib.mkForce false;
  };
}
