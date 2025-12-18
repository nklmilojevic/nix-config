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

    claude-code-overlay = {
      url = "github:nklmilojevic/claude-code-overlay";
    };

    codex-cli-nix = {
      url = "github:nklmilojevic/codex-cli-nix";
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
    claude-code-overlay,
    codex-cli-nix,
    ...
  } @ inputs: let
    overlays = [
      claude-code-overlay.overlays.default
      (final: prev: {
        codex = codex-cli-nix.packages.${final.system}.default;
      })
    ];
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
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };
}
