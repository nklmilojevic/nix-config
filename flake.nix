{
  description = "Nikola's flake for system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
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

    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:nklmilojevic/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:nklmilojevic/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-nix = {
      url = "github:nklmilojevic/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gemini-cli-nix = {
      url = "github:nklmilojevic/gemini-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    talosctl = {
      url = "github:nklmilojevic/talosctl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mailersend-cli = {
      url = "github:mailersend/mailersend-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mailerlite-cli = {
      url = "github:mailerlite/mailerlite-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    atuin-nix = {
      url = "github:nklmilojevic/atuin-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sofka = {
      url = "github:nklmilojevic/sofka";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt release binaries, not a source build: upstream publishes no
    # binary cache, so building from its flake costs a full Rust/Bun compile.
    herdr = {
      url = "github:nklmilojevic/herdr-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omp = {
      url = "github:nklmilojevic/omp-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      darwin,
      nix-homebrew,
      nixvim,
      krewfile,
      catppuccin,
      claude-code-overlay,
      codex-cli-nix,
      opencode-nix,
      gemini-cli-nix,
      talosctl,
      mailersend-cli,
      mailerlite-cli,
      atuin-nix,
      sofka,
      herdr,
      omp,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      overlays = [
        claude-code-overlay.overlays.default
        talosctl.overlays.default
        sofka.overlays.default
        herdr.overlays.default
        omp.overlays.default
        (
          final: prev:
          let
            system = final.stdenv.hostPlatform.system;
            stable = import nixpkgs-stable { inherit system; };
          in
          {
            # nixpkgs lags behind bun releases; bump to the official prebuilt
            # binary. Drop this once nixpkgs-unstable reaches the same version.
            bun = prev.bun.overrideAttrs (
              let
                version = "1.4.0";
                sources = {
                  aarch64-darwin = {
                    url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
                    hash = "sha256-xmnpf2Fk4cluBwF0jbmN+ndJKQjL2DlMdVcTSnNd44E=";
                  };
                  aarch64-linux = {
                    url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
                    hash = "sha256-SxozLuhhmD65O8/m93D/+U4+MbLDiL2uo8jtNeWO7Q4=";
                  };
                  x86_64-linux = {
                    url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
                    hash = "sha256-GE+0WV8NQBohfPfHjBvEMLqDMU2reouUgFurv3+nCX8=";
                  };
                };
              in
              {
                inherit version;
                src = final.fetchurl sources.${system};
              }
            );
            codex = codex-cli-nix.packages.${system}.default;
            opencode = opencode-nix.packages.${system}.default;
            gemini-cli = gemini-cli-nix.packages.${system}.default;
            mailersend = mailersend-cli.packages.${system}.default;
            mailerlite = mailerlite-cli.packages.${system}.default;
            atuin = atuin-nix.packages.${system}.default;
            inherit (stable)
              direnv
              pwgen
              rclone
              ;
          }
        )
      ];
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Import custom library functions
      lib = import ./lib { lib = nixpkgs.lib; };
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          inherit (pkgs) k9s;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixpkgs-fmt
            nil
          ];
        };

      }
    )
    // {
      # Expose library functions for external use
      lib = lib;

      darwinConfigurations.daedalus = darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.overlays = overlays; }
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
        specialArgs = { inherit inputs; };
      };

      homeConfigurations =
        let
          mkLinuxHome =
            system:
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
              };
              modules = [
                ./hosts/linux
                catppuccin.homeModules.catppuccin
              ];
              extraSpecialArgs = { inherit inputs; };
            };
        in
        {
          # x86_64 Linux
          linux = mkLinuxHome "x86_64-linux";
          server = mkLinuxHome "x86_64-linux";
          # aarch64 Linux
          "linux-aarch64" = mkLinuxHome "aarch64-linux";
          "server-aarch64" = mkLinuxHome "aarch64-linux";
        };
    };
}
