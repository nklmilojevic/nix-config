# Declarative herdr plugins.
#
# herdr has no native declarative plugin mechanism: it tracks plugins in a
# mutable registry (~/.config/herdr/plugins.json) that its CLI owns. So each
# plugin is built as a nix derivation laid out exactly like its repo (manifests
# reference relative paths such as ./bin/<tool>), and an activation hook
# registers the store path with `herdr plugin link` — link never runs a
# plugin's [[build]] commands, which is correct here because nix already built
# everything. Per-plugin runtime state (~/.config/herdr/plugins/config/<id>)
# stays out of nix on purpose: the plugins write it at runtime.
{ pkgs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;

  # Pure bash plugin, no build step. Requires herdr >= 0.7.4 (native popup
  # placement) plus tmux and jq on PATH for persistence.
  herdr-float = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-plugin-float";
    version = "0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "meerzulee";
      repo = "herdr-float";
      rev = "6301b7e2c96c26b136b8bf31f5618f4970c529ce";
      hash = "sha256-+1XFZhhWo6/310ncRfhjRI5CHNtbZL7RetsTwTbCLsM=";
    };
    dontConfigure = true;
    dontBuild = true;
    # The hide key lives in the plugin's embedded tmux, not in herdr; keep it
    # in sync with the ctrl+f toggle binding in config.toml (M-f stays as a
    # fallback).
    postPatch = ''
      printf 'bind-key -n C-f detach-client\n' >> tmux.conf
      substituteInPlace herdr-plugin.toml \
        --replace-fail "Alt/Option-F to hide" "Ctrl-F to hide"
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R ./. $out/
      runHook postInstall
    '';
  };

  # herdr-lazygit pins lazygit 0.63.0 and fzf 0.74.0 (its generated config and
  # key-conflict analysis are tested against exactly these). Its runtime
  # resolves $HERDR_PLUGIN_ROOT/bin/{lazygit,fzf} by absolute path, so we place
  # the pinned upstream release binaries there instead of letting
  # scripts/install-runtime.sh download them at install time. Digests below are
  # the plugin's own repository-pinned SHA-256 values.
  lazygitRuntime =
    {
      aarch64-darwin = {
        lazygitAsset = "lazygit_0.63.0_darwin_arm64.tar.gz";
        lazygitHash = "sha256-YOa/KaFQGlep0HhTiqV2obTbRXedsuPdaTGnIH9WCpw=";
        fzfAsset = "fzf-0.74.0-darwin_arm64.tar.gz";
        fzfHash = "sha256-2mDomA5COaD8Xx/P6HPyQ9/ak6ahO2lrAOHchYSneoc=";
      };
      x86_64-darwin = {
        lazygitAsset = "lazygit_0.63.0_darwin_x86_64.tar.gz";
        lazygitHash = "sha256-MEsb9/e7taXVnjQUW85j1CczzYKOT+QUKM7Z7k2/6UI=";
        fzfAsset = "fzf-0.74.0-darwin_amd64.tar.gz";
        fzfHash = "sha256-4sRw8FisGGFfVMC+vg/SlW8qqOMGoRYheDoAqqOG7t0=";
      };
      aarch64-linux = {
        lazygitAsset = "lazygit_0.63.0_linux_arm64.tar.gz";
        lazygitHash = "sha256-qsFHq/XOQ6/mrovLFLDUeREZdaGJMC16mTht7KcNV/c=";
        fzfAsset = "fzf-0.74.0-linux_arm64.tar.gz";
        fzfHash = "sha256-vZ5hZevbcCIV1CNoy7lbjdcKTnful5Ja2sjDFmDjDvc=";
      };
      x86_64-linux = {
        lazygitAsset = "lazygit_0.63.0_linux_x86_64.tar.gz";
        lazygitHash = "sha256-z1z6PhFtd3XzYApR7B2c57pVSgi5Vmx8Lag8sAI++r8=";
        fzfAsset = "fzf-0.74.0-linux_amd64.tar.gz";
        fzfHash = "sha256-z5GfBbdYG0x0TXZOqnBGZdYd1tPKeF8N8jUSgd/2DNo=";
      };
    }
    .${system} or (throw "herdr-lazygit: no pinned runtime binaries for ${system}");

  lazygitTarball = pkgs.fetchurl {
    url = "https://github.com/jesseduffield/lazygit/releases/download/v0.63.0/${lazygitRuntime.lazygitAsset}";
    hash = lazygitRuntime.lazygitHash;
  };

  fzfTarball = pkgs.fetchurl {
    url = "https://github.com/junegunn/fzf/releases/download/v0.74.0/${lazygitRuntime.fzfAsset}";
    hash = lazygitRuntime.fzfHash;
  };

  lazygitSrc = pkgs.fetchFromGitHub {
    owner = "crokily";
    repo = "herdr-lazygit";
    rev = "a13e12c99e5e469edd73165cabba413c2a2fd698"; # v0.3.0
    hash = "sha256-9BxHBMoXogQPBWbwm+ewV8Pb5uQ8uxrhQe1eSu1DU4c=";
  };

  herdr-lazygit = pkgs.runCommand "herdr-plugin-lazygit-0.3.0" { } ''
    mkdir -p $out/bin
    cp -R ${lazygitSrc}/. $out/
    chmod -R u+w $out
    tar -xzf ${lazygitTarball} lazygit
    install -m755 lazygit $out/bin/lazygit
    tar -xzf ${fzfTarball} fzf
    install -m755 fzf $out/bin/fzf
  '';

  tabTitleSrc = pkgs.fetchFromGitHub {
    owner = "aarsh21";
    repo = "herdr-tab-title";
    rev = "2e85b286035803fb4cd1befb94b66111dad2cf1c"; # v0.1.6
    hash = "sha256-dnS0eOtQhC/AZmvZMu/CnwfbXz1mqeCAFkwHXeGK0ig=";
  };

  # Vendored copy of the plugin's Cargo.lock (avoids cargoHash churn and IFD).
  tabTitleBin = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-tab-title";
    version = "0.1.6";
    src = tabTitleSrc;
    cargoLock.lockFile = ./herdr-tab-title-Cargo.lock;
    doCheck = false;
  };

  herdr-tab-title = pkgs.runCommand "herdr-plugin-tab-title-0.1.6" { } ''
    mkdir -p $out/bin
    cp -R ${tabTitleSrc}/. $out/
    chmod -R u+w $out
    install -m755 ${tabTitleBin}/bin/herdr-tab-title $out/bin/herdr-tab-title
  '';

  # Release tarballs are the complete plugin layout (manifest + bin/herdr-sesh),
  # so no source checkout or Go build is needed.
  seshAsset =
    {
      aarch64-darwin = {
        suffix = "darwin_arm64";
        hash = "sha256-+r93W8n4I4iG3xcT97i6X2UTSbyxTovMEhX8ap5BpWY=";
      };
      x86_64-darwin = {
        suffix = "darwin_amd64";
        hash = "sha256-by+fLdt3CE/YNy2pA9OTzGmQyAN9eNQWiLyjsE6rXFU=";
      };
      aarch64-linux = {
        suffix = "linux_arm64";
        hash = "sha256-uxGfNemlD2qEvyk+9a1l1bwjm+qs4btZVG511Ay76QM=";
      };
      x86_64-linux = {
        suffix = "linux_amd64";
        hash = "sha256-sPNKpmaHDgR7aijIXrdgOD99GevHZZct2Q7ptnFVnCY=";
      };
    }
    .${system} or (throw "herdr-sesh: no release binary for ${system}");

  herdr-sesh = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-plugin-sesh";
    version = "0.6.0";
    src = pkgs.fetchurl {
      url = "https://github.com/fullerzz/herdr-plugin-sesh/releases/download/v0.6.0/herdr-sesh_0.6.0_${seshAsset.suffix}.tar.gz";
      inherit (seshAsset) hash;
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R ./. $out/
      runHook postInstall
    '';
  };

  plugins = [
    {
      id = "herdr-float";
      package = herdr-float;
    }
    {
      id = "herdr-lazygit";
      package = herdr-lazygit;
    }
    {
      id = "aarsh21.tab-title";
      package = herdr-tab-title;
    }
    {
      id = "fullerzz.sesh";
      package = herdr-sesh;
    }
  ];
in
{
  # Registers each plugin's store path in herdr's registry. Idempotent: skips
  # plugins already linked at the right path, replaces stale links (or older
  # `herdr plugin install`-managed copies) on version bumps. Failures warn
  # instead of aborting activation.
  home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    herdrPluginSync() {
      local id="$1" want="$2" have
      have=$(${pkgs.herdr}/bin/herdr plugin list --plugin "$id" --json 2>/dev/null \
        | ${pkgs.jq}/bin/jq -r '.result.plugins[0].plugin_root // empty') || have=""
      if [ "$have" = "$want" ]; then
        return 0
      fi
      if [ -n "$have" ]; then
        run ${pkgs.herdr}/bin/herdr plugin unlink "$id" 2>/dev/null \
          || run ${pkgs.herdr}/bin/herdr plugin uninstall "$id" 2>/dev/null \
          || true
      fi
      if run ${pkgs.herdr}/bin/herdr plugin link "$want"; then
        noteEcho "herdr plugin '$id' linked -> $want"
      else
        warnEcho "herdr plugin '$id' could not be linked from $want"
      fi
    }
    ${lib.concatMapStrings (p: ''
      herdrPluginSync ${lib.escapeShellArg p.id} ${lib.escapeShellArg "${p.package}"}
    '') plugins}
  '';
}
