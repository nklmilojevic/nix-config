{
  description = "Nikola's flake for system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # Not used directly. Declared so every input below can `follows` them,
    # which collapses the duplicate transitive copies in flake.lock.
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
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

    homebrew-logi = {
      url = "github:nklmilojevic/homebrew-logi";
      flake = false;
    };

    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    claude-code-overlay = {
      url = "github:nklmilojevic/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    codex-cli-nix = {
      url = "github:nklmilojevic/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    opencode-nix = {
      url = "github:nklmilojevic/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    gemini-cli-nix = {
      url = "github:nklmilojevic/gemini-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    talosctl = {
      url = "github:nklmilojevic/talosctl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    mailersend-cli = {
      url = "github:mailersend/mailersend-cli";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    mailerlite-cli = {
      url = "github:mailerlite/mailerlite-cli";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    atuin-nix = {
      url = "github:nklmilojevic/atuin-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    sofka = {
      url = "github:nklmilojevic/sofka";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Prebuilt release binaries, not a source build: upstream publishes no
    # binary cache, so building from its flake costs a full Rust/Bun compile.
    herdr = {
      url = "github:nklmilojevic/herdr-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    omp = {
      url = "github:nklmilojevic/omp-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    pi = {
      url = "github:nklmilojevic/pi-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    varlock = {
      url = "github:nklmilojevic/varlock-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      home-manager,
      darwin,
      nix-homebrew,
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
      pi,
      varlock,
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
        pi.overlays.default
        varlock.overlays.default
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
            # tmux 3.7 configure aborts on darwin unless jemalloc is explicitly
            # chosen; pinned nixpkgs passes neither flag. Drop once nixpkgs
            # handles it upstream.
            tmux = prev.tmux.overrideAttrs (old: {
              configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-jemalloc" ];
            });
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
      lib = import ./lib { inherit (nixpkgs) lib; };
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
        # Derivations this repo patches or pins itself, exposed so CI can build
        # and push them to Cachix and so other machines can build them directly.
        packages = {
          inherit (pkgs) bun k9s tmux;
          starship = import ./modules/shared/programs/starship/package.nix { inherit pkgs; };
        };

        formatter = pkgs.nixfmt-tree;

        checks.lint =
          pkgs.runCommand "nix-config-lint"
            {
              nativeBuildInputs = with pkgs; [
                deadnix
                nixfmt
                statix
              ];
            }
            ''
              cd ${./.}
              find . -name '*.nix' -exec nixfmt --check {} +
              statix check .
              deadnix --fail .
              touch $out
            '';

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            deadnix
            just
            nil
            nixfmt
            statix
          ];
        };
      }
    )
    // {
      # Expose library functions for external use
      inherit lib;

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
                "nklmilojevic/homebrew-logi" = inputs.homebrew-logi;
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
