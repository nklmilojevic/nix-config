{...}: {
  nix.settings = {
    substituters = [
      "https://nkl-nix-config.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nkl-nix-config.cachix.org-1:BFC4/yovGI+0E8ZZE0K3H6Mu2uBaqSU/kTnSvFQs5uE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
