{ lib, ... }:
{
  # Native fish prompt (replaces starship). Sourced last so its space/backspace
  # bindings win over plugin bindings.
  programs.fish.interactiveShellInit = lib.mkAfter ''
    source ${./prompt.fish}
  '';
}
