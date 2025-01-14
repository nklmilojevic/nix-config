{...}: {
  programs.lsd = {
    enable = true;
    enableAliases = false;
    settings = {
      icons = {
        when = "never";
        separator = " ";
      };
    };
    colors = {
      user = "#cba6f7";
      group = "#b4befe";
      permission = {
        read = "#a6e3a1";
        write = "#f9e2af";
        exec = "#eba0ac";
        exec-sticky = "#cba6f7";
        no-access = "#a6adc8";
        octal = "#94e2d5";
        acl = "#94e2d5";
        context = "#89dceb";
      };
      date = {
        hour-old = "#94e2d5";
        day-old = "#89dceb";
        older = "#74c7ec";
      };
      size = {
        none = "#a6adc8";
        small = "#a6e3a1";
        medium = "#f9e2af";
        large = "#fab387";
      };
      inode = {
        valid = "#f5c2e7";
        invalid = "#a6adc8";
      };
      links = {
        valid = "#f5c2e7";
        invalid = "#a6adc8";
      };
      tree-edge = "#bac2de";
      git-status = {
        default = "#cdd6f4";
        unmodified = "#a6adc8";
        ignored = "#a6adc8";
        new-in-index = "#a6e3a1";
        new-in-workdir = "#a6e3a1";
        typechange = "#f9e2af";
        deleted = "#f38ba8";
        renamed = "#a6e3a1";
        modified = "#f9e2af";
        conflicted = "#f38ba8";
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
