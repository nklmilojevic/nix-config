_: {
  # Nix picks a substituter by its advertised priority, not by list order, so
  # every entry sets one explicitly: own caches first, then upstream. Lower
  # number wins. Defaults are 40 for cache.nixos.org and 41 for cachix.
  nix.settings = {
    substituters = [
      "https://nkl-nix-config.cachix.org?priority=30"
      "https://nkl-sofka.cachix.org?priority=31"
      "https://opencode-nix-cache.cachix.org?priority=32"
      "https://cache.nixos.org/?priority=40"
      "https://nix-community.cachix.org?priority=41"
      "https://devenv.cachix.org?priority=42"
    ];
    trusted-public-keys = [
      "nkl-nix-config.cachix.org-1:BFC4/yovGI+0E8ZZE0K3H6Mu2uBaqSU/kTnSvFQs5uE="
      "nkl-sofka.cachix.org-1:hLg9frFNJynrxe7SSBb/p6pbawlpZmG10bw+wLsTufw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "opencode-nix-cache.cachix.org-1:Wq9yk7XD0pg457w4D5HV2OJVj++tl70tfzde1SrfYX8="
    ];
  };
}
