{ ... }:
{
  nix.settings = {
    substituters = [
      "https://nkl-nix-config.cachix.org"
      "https://nkl-sofka.cachix.org"
      "https://nix-community.cachix.org"
      "https://opencode-nix-cache.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nkl-nix-config.cachix.org-1:BFC4/yovGI+0E8ZZE0K3H6Mu2uBaqSU/kTnSvFQs5uE="
      "nkl-sofka.cachix.org-1:hLg9frFNJynrxe7SSBb/p6pbawlpZmG10bw+wLsTufw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "opencode-nix-cache.cachix.org-1:Wq9yk7XD0pg457w4D5HV2OJVj++tl70tfzde1SrfYX8="
    ];
  };
}
