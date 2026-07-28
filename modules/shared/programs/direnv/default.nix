{ pkgs, lib, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    config = {
      hide_env_diff = true;
    };
    stdlib = ''
      # Add your direnvrc configuration here
      # For example:
      layout_uv() {
          if [[ -d ".venv" ]]; then
              VIRTUAL_ENV="$(pwd)/.venv"
          fi

          if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
              log_status "No virtual environment exists. Executing \`uv venv\` to create one."
              uv venv
              VIRTUAL_ENV="$(pwd)/.venv"
          fi

          PATH_add "$VIRTUAL_ENV/bin"
          export UV_ACTIVE=1  # or VENV_ACTIVE=1
          export VIRTUAL_ENV
      }
    '';
  };

  # No native home-manager option for devenv yet; mirror how the direnv
  # module ships nix-direnv (direnv sources lib/*.sh before every .envrc).
  # Must stay lazy: devenv's direnvrc and nix-direnv define the same _nix_*
  # helper names, and hm-nix-direnv.sh loads after this file, so an eager
  # eval gets its helpers clobbered (DEVENV_BIN never set -> empty command).
  # The eval below redefines use_devenv, which the trailing call dispatches to.
  xdg.configFile."direnv/lib/hm-devenv.sh".text = ''
    use_devenv() {
      eval "$(${lib.getExe pkgs.devenv} direnvrc)"
      use_devenv "$@"
    }
  '';
}
