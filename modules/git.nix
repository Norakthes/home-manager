{ lib, ... }:
{
  programs.git = {
    enable = true;

    # Hosts with a GPG key (yubikey, fedora) override this. Elsewhere sign
    # with the ssh key; GitHub needs it added a second time as a signing key.
    signing = {
      signByDefault = true;
      format = lib.mkDefault "ssh";
      key = lib.mkDefault "~/.ssh/id_ed25519.pub";
    };

    settings = {
      user = {
        name = "Rasmus Bødker";
        email = "rasmus.b.bodker@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";

      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        selectedLineBgColor = [ "reverse" ];
      };
    };
  };
}
