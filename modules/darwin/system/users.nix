{ pkgs, user, ... }:
{
  system.primaryUser = user;

  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.fish;
  };

  environment.shells = with pkgs; [
    bashInteractive
    fish
    zsh
  ];

  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

  # nix-darwin resets PATH in every bash/zsh, dropping the rex CLI that Rex
  # terminals prepend; put it back first.
  environment.interactiveShellInit = ''
    if [ -n "$REX_BIN_DIR" ]; then
      export PATH="$REX_BIN_DIR:$PATH"
    fi
  '';

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
}
