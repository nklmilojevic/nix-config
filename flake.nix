{
  description = "Nikola's flake for system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

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

    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    darwin,
    nix-homebrew,
    krewfile,
    catppuccin,
    ...
  } @ inputs: let
    overlays = [];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in {
      packages = {
        inherit (pkgs) k9s;
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixpkgs-fmt
          nil
        ];
      };

      packages.homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/linux
          catppuccin.homeModules.catppuccin
        ];
        extraSpecialArgs = {inherit inputs;};
      };
    })
    // {
      darwinConfigurations.daedalus = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          inherit overlays;
          config.allowUnfree = true;
        };
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/darwin
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "nkl";
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
              };
              mutableTaps = true;
            };

            # TODO: Remove below anonymous/lambda function block after https://github.com/NixOS/nixpkgs/pull/461779 is resolved upstream.
            # nixpkgs.overlays = [
            #   (_self: super: {
            #     fish = super.fish.overrideAttrs (oldAttrs: {
            #       doCheck = false;
            #       checkPhase = "";
            #       cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
            #         "-DBUILD_TESTING=OFF"
            #       ];
            #     });
            #   })
            # ];
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };
}
