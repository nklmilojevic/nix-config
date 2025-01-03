{...}: {
  programs.eza = {
    enable = true;
    icons = "auto";
    extraOptions = [
      "--group"
      "--color=auto"
      "--no-quotes"
      "--color-scale"
      "--classify"
    ];
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
