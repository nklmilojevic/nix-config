{ lib, pkgs, ... }:
{
  # Touch ID for sudo. pam_reattach is added by hand rather than via
  # `reattach = true` to keep `ignore_ssh`; mkBefore keeps it above pam_tid.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    text = lib.mkBefore "auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh";
  };
}
