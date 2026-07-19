# nix-config

## Starship `detect_input` patch

`modules/shared/programs/starship/detect-input.patch` adds a custom `detect_input` feature to starship (modules appear while typing a matching command, e.g. `k `/`kubectl ` reveals the kubernetes module — upstream issues starship/starship#5509, #5999). It is applied on top of the nixpkgs `starship` package via `overrideAttrs` in `modules/shared/programs/starship/default.nix`. The patch adds no cargo dependencies, so `cargoHash` never needs to change.

### When the starship build fails after a version bump

A nixpkgs starship update can make the patch stop applying. The failure is loud: the build aborts in the patch phase with `Hunk FAILED` / `can't find file to patch`.

To regenerate the patch:

1. Go to the local starship clone at `~/dev/personal/starship` (clone of `github.com/starship/starship`; it exists only as the patch workshop). Fetch and check out the tag matching the new nixpkgs version:

   ```fish
   cd ~/dev/personal/starship
   git fetch --tags origin
   git checkout vX.Y.Z
   ```

2. Re-apply the current patch with three-way merge and resolve any conflicts:

   ```fish
   git apply --3way ~/nix-config/modules/shared/programs/starship/detect-input.patch
   ```

   The patch touches: `src/context.rs` (`--input` flag on `Properties`, `Context::detect_input()` regex helper), `src/configs/kubernetes.rs` + `src/modules/kubernetes.rs` (`detect_input` option and gating), `src/init/starship.fish` (passes `--input`, defines `enable_input_detection`/`disable_input_detection`), and `src/test/mod.rs` (`.input()` test builder).

3. Verify: `cargo test --lib kubernetes` must pass, including `test_detect_input`. Do NOT run the full test suite with default env — test contexts read the real `~/.config/starship.toml` palette and ~200 color assertions fail spuriously. If a full run is needed, redirect HOME:

   ```fish
   env HOME=/tmp/starship-test-home RUSTUP_HOME=$HOME/.rustup CARGO_HOME=$HOME/.cargo RUSTUP_TOOLCHAIN=stable cargo test --lib
   ```

4. Export the regenerated patch (only `src/`, never `.github/config-schema.json` — the schema churns every release and isn't needed for the nix build):

   ```fish
   git diff -- src/ > ~/nix-config/modules/shared/programs/starship/detect-input.patch
   ```

5. Validate the nix build before switching:

   ```fish
   nix build --impure --no-link --expr '
   let
     flake = builtins.getFlake "git+file:///Users/nkl/nix-config?dirty=1";
     pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
   in
   pkgs.starship.overrideAttrs (old: {
     patches = (old.patches or [ ]) ++ [ /Users/nkl/nix-config/modules/shared/programs/starship/detect-input.patch ];
   })'
   ```

If upstream ever ships a native show-on-command / `detect_input` feature, drop the patch and the `package` override in `modules/shared/programs/starship/default.nix` instead of regenerating, and keep the `kubernetes.detect_input` setting only if the upstream option is compatible.
