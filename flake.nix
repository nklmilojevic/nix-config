{
  description = "Nikola's flake for system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:catppuccin/nix";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    opencode-nix = {
      url = "github:nklmilojevic/opencode-nix";
    };

    gemini-cli-nix = {
      url = "github:nklmilojevic/gemini-cli-nix";
    };

    talosctl = {
      url = "github:nklmilojevic/talosctl-flake";
    };

    mailersend-cli = {
      url = "github:mailersend/mailersend-cli";
    };

    mailerlite-cli = {
      url = "github:mailerlite/mailerlite-cli";
    };

    atuin-nix = {
      url = "github:nklmilojevic/atuin-nix";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , home-manager
    , darwin
    , nix-homebrew
    , nixvim
    , krewfile
    , catppuccin
    , claude-code-overlay
    , codex-cli-nix
    , opencode-nix
    , gemini-cli-nix
    , talosctl
    , mailersend-cli
    , mailerlite-cli
    , atuin-nix
    , nixpkgs-stable
    , ...
    } @ inputs:
    let
      overlays = [
        claude-code-overlay.overlays.default
        talosctl.overlays.default
        (final: prev:
          let
            system = final.stdenv.hostPlatform.system;
          in
          {
            codex = codex-cli-nix.packages.${system}.default;
            opencode = opencode-nix.packages.${system}.default;
            gemini-cli = gemini-cli-nix.packages.${system}.default;
            mailersend = mailersend-cli.packages.${system}.default;
            mailerlite = mailerlite-cli.packages.${system}.default;
            atuin = atuin-nix.packages.${system}.default;
            direnv = (import nixpkgs-stable { inherit system; }).direnv;
          })
      ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      # Import custom library functions
      lib = import ./lib { lib = nixpkgs.lib; };
    in
    flake-utils.lib.eachSystem supportedSystems
      (system:
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
            nixpkgs-fmt
            nil
          ];
        };

      })
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
          mkLinuxHome = system: home-manager.lib.homeManagerConfiguration {
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
