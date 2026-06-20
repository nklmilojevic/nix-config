{ ... }:
{
  programs.lsd = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      icons = {
        when = "never";
        separator = " ";
      };
    };
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      ll = "lsd -lha";
      la = "lsd -A";
      lt = "lsd --tree";
      lla = "lsd -lA";
      llt = "lsd -l --tree";
    };
  };
}
