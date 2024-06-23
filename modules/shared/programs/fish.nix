{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      fish_add_path "/Users/nkl/.nix-profile/bin"
      fish_add_path "/Users/nkl/.local/bin"
      fish_add_path "/Users/nkl/bin"
      fish_add_path "/Users/nkl/.krew/bin"

      set -gx SOPS_AGE_KEY_FILE /Users/nkl/.config/sops/age/keys.txt
      set -gx EDITOR vim
      set -gx LANG en_US.UTF-8
      set -gx LC_ALL en_US.UTF-8
      set -gx HOMEBREW_NO_ANALYTICS 1

      set -gx SSH_AUTH_SOCK /Users/nkl/.1password/agent.sock

      nix-your-shell fish | source
    '';

    plugins = [
      { name = "puffer"; src = pkgs.fishPlugins.puffer.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      {
        name = "zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "zoxide.fish";
          rev = "bfd5947bcc7cd01beb23c6a40ca9807c174bba0e";
          sha256 = "Hq9UXB99kmbWKUVFDeJL790P8ek+xZR5LDvS+Qih+N4=";
        };
      }
      {
        name = "fisher-plugin-macos";
        src = pkgs.fetchFromGitHub {
          owner = "edheltzel";
          repo = "fisher-plugin-macos";
          rev = "5b4c5815040eca670c4f552b575a60d3f05af2ea";
          sha256 = "sha256-TiAo6YzN4aRaMlZEvXlIR9xhYkEiGMSdKYnomEnfGCk=";
        };
      }
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          sha256 = "sha256-Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
        };
      }
    ];

    shellAliases = {
      k = "kubectl";
      vim = "nvim";
      df = "df -h";
      mkdir = "mkdir -p -v";
      ll = "ls -lha";
      lg = "lazygit";
      grep = "rg";
      cat = "bat --theme Dracula --paging=never --style plain $argv";
    };

    functions = {
      psgrep = {
        argumentNames = [ "process" ];
        description = "greps for processes";
        body = "ps aux | rg $process | rg -v rg";
      };
    };
  };
}
