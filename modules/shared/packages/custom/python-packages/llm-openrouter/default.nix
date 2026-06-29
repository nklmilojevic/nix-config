{ pkgs }:
pkgs.python314Packages.buildPythonPackage rec {
  pname = "llm-openrouter";
  version = "0.6";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "simonw";
    repo = "llm-openrouter";
    rev = version;
    sha256 = "";
  };

  propagatedBuildInputs = with pkgs.python314Packages; [ llm ];
}
