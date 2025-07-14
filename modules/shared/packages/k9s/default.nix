{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "k9s";
  version = "0.50.6";

  src = fetchFromGitHub {
    owner = "derailed";
    repo = "k9s";
    rev = "v${version}";
    sha256 = "sha256-cL7OD9OtkVx325KcANU8FudcOk6HMct6ve2p0qSkEoc=";
  };

  vendorHash = "sha256-EgYeQenlSaA08uS4Un7+wukAvKfoi9u0BxLGwpBM1sc=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/derailed/k9s/cmd.version=${version}"
    "-X github.com/derailed/k9s/cmd.commit=${src.rev}"
  ];

  meta = with lib; {
    description = "Kubernetes CLI To Manage Your Clusters In Style";
    homepage = "https://github.com/derailed/k9s";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    mainProgram = "k9s";
  };
}
