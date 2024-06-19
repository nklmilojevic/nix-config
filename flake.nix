{
  description = "Nikola's flake for system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, homebrew-core, homebrew-cask, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in
    {
      darwinConfigurations."daedalus" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nkl = import ./home/home.nix;
          }
          ./hosts/mac/configuration.nix
          ./hosts/mac/homebrew.nix
          ./hosts/mac/darwin-settings.nix
          ./hosts/mac/shell.nix
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;

              user = "nkl";

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };

              mutableTaps = true;
            };
          }
        ];
      };

      homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./home/home.nix
          ./hosts/linux/configuration.nix
        ];
      };
    };
}
