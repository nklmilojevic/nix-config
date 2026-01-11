# Custom package definitions
{pkgs}: {
  llm-openrouter = pkgs.callPackage ./python-packages/llm-openrouter {};
}
