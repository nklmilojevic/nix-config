{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
let
  version = "2.7.1";
  # Release assets are named after Vikunja's own build targets.
  sources = {
    aarch64-darwin = {
      target = "darwin-10.15-arm64";
      hash = "sha256-c4D91LR5/8MWOF9ZfbpVfeMiWgpYXJB7q80F1OXgiPc=";
    };
    x86_64-linux = {
      target = "linux-amd64";
      hash = "sha256-MDSGXo1MU47QdlwsKXEqpYWl9UsbIQ9lMj2zR9FW/CY=";
    };
    aarch64-linux = {
      target = "linux-arm64";
      hash = "sha256-jcNWUnrMA0imZiSxL04A37t7FcPXhwdFqNNVa+9Goss=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "veans: unsupported system ${stdenvNoCC.hostPlatform.system}");
  asset = "veans-v${version}-${source.target}";
in
stdenvNoCC.mkDerivation {
  pname = "veans";
  inherit version;

  src = fetchurl {
    url = "https://github.com/go-vikunja/vikunja/releases/download/v${version}/${asset}-full.zip";
    inherit (source) hash;
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 ${asset} $out/bin/veans
    runHook postInstall
  '';

  meta = {
    description = "Agent task tracking on a Vikunja board";
    homepage = "https://github.com/go-vikunja/vikunja/tree/main/veans";
    license = lib.licenses.agpl3Plus;
    platforms = builtins.attrNames sources;
    mainProgram = "veans";
  };
}
