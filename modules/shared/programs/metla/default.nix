# metla: finds finished git worktrees under ~/dev and removes them on request.
{ inputs, ... }:
{
  imports = [ inputs.metla.homeManagerModules.default ];

  programs.metla.enable = true;
}
