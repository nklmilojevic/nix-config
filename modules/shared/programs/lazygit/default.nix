{pkgs, ...}: {
  config = {
    home.packages = [
      pkgs.lazygit
    ];

    catppuccin = {
      lazygit = {
        enable = true;
      };
    };

    programs.lazygit = {
      enable = true;
    };
  };
}
