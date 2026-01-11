{pkgs}:
pkgs.python313Packages.buildPythonPackage rec {
  pname = "llm-openrouter";
  version = "0.4.1";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "simonw";
    repo = "llm-openrouter";
    rev = version;
    sha256 = "0n5rj8yfhh4k87g5qy9kkmpn3274icswvrpy7bfa8sl4gb4n8c52";
  };

  propagatedBuildInputs = with pkgs.python313Packages; [llm];
}
