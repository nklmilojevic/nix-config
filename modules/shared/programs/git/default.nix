{config, ...}: {
  programs.git = {
    enable = true;
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrYywYsK/kocVOa48LjaOR2X10g7lwsB1PtkyBJX800";

    settings = {
      user.name = "Nikola Milojević";
      user.email = "nikola@milojevic.me";
      pull.rebase = false;
      init.defaultBranch = "main";
      core.excludesFile = "${config.home.homeDirectory}/.gitignore";
      commit.gpgSign = true;
      tag.gpgSign = true;
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      diff."ansible-vault".textconv = "ansible-vault view";
    };
  };
}
