{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    # Ghostty is installed via Homebrew on darwin; HM's package isn't built for macOS.
    package = null;
    installBatSyntax = false;

    settings = {
      theme = "Catppuccin Mocha";

      font-family = "TX-02 Retina ExtraCondensed";
      font-family-italic = "TX-02 Retina ExtraCondensed Oblique";
      font-family-bold = "TX-02 SemiBold ExtraCondensed";
      font-size = 16;
      font-thicken = true;
      font-thicken-strength = 88;

      macos-titlebar-style = "hidden";
      macos-icon = "custom";
      macos-icon-frame = "aluminum";
      macos-icon-ghost-color = "#44475a";
      macos-icon-screen-color = "#1e1f29,#44475a";

      window-padding-balance = false;
      window-padding-x = "10,3";
      window-padding-y = 10;
      alpha-blending = "linear-corrected";

      keybind = [
        "shift+enter=text:\\x1b\\r"

        "cmd+KeyT=text:\\x1b[32;5ut"
        "cmd+t=unbind"
        "cmd+KeyN=text:\\x1b[32;5un"
        "cmd+n=unbind"
        "cmd+KeyW=text:\\x1b[32;5uW"
        "cmd+w=unbind"
        "cmd+KeyK=text:\\x1b[32;5uN"
        "cmd+k=unbind"
        "cmd+KeyL=text:\\x1b[32;5uT"
        "cmd+l=unbind"
        "alt+t=text:\\x1b[32;5ut"

        # herdr prefix (ctrl+space): normalize the physical press to CSI-u so
        # herdr never sees a bare NUL byte
        "ctrl+space=text:\\x1b[32;5u"

        # ctrl+tab cycles herdr workspaces; ctrl+option+tab cycles herdr tabs
        "ctrl+tab=text:\\x1b[9;5u"
        "ctrl+shift+tab=text:\\x1b[9;6u"
        "ctrl+alt+tab=text:\\x1b[9;7u"
        "ctrl+alt+shift+tab=text:\\x1b[9;8u"

        # cmd+1..9 jumps herdr tabs; ctrl+1..9 jumps herdr workspaces
        "cmd+digit_1=text:\\x1b[49;3u"
        "cmd+1=text:\\x1b[49;3u"
        "cmd+digit_2=text:\\x1b[50;3u"
        "cmd+2=text:\\x1b[50;3u"
        "cmd+digit_3=text:\\x1b[51;3u"
        "cmd+3=text:\\x1b[51;3u"
        "cmd+digit_4=text:\\x1b[52;3u"
        "cmd+4=text:\\x1b[52;3u"
        "cmd+digit_5=text:\\x1b[53;3u"
        "cmd+5=text:\\x1b[53;3u"
        "cmd+digit_6=text:\\x1b[54;3u"
        "cmd+6=text:\\x1b[54;3u"
        "cmd+digit_7=text:\\x1b[55;3u"
        "cmd+7=text:\\x1b[55;3u"
        "cmd+digit_8=text:\\x1b[56;3u"
        "cmd+8=text:\\x1b[56;3u"
        "cmd+digit_9=text:\\x1b[57;3u"
        "cmd+9=text:\\x1b[57;3u"
        "ctrl+digit_1=text:\\x1b[49;6u"
        "ctrl+1=text:\\x1b[49;6u"
        "ctrl+digit_2=text:\\x1b[50;6u"
        "ctrl+2=text:\\x1b[50;6u"
        "ctrl+digit_3=text:\\x1b[51;6u"
        "ctrl+3=text:\\x1b[51;6u"
        "ctrl+digit_4=text:\\x1b[52;6u"
        "ctrl+4=text:\\x1b[52;6u"
        "ctrl+digit_5=text:\\x1b[53;6u"
        "ctrl+5=text:\\x1b[53;6u"
        "ctrl+digit_6=text:\\x1b[54;6u"
        "ctrl+6=text:\\x1b[54;6u"
        "ctrl+digit_7=text:\\x1b[55;6u"
        "ctrl+7=text:\\x1b[55;6u"
        "ctrl+digit_8=text:\\x1b[56;6u"
        "ctrl+8=text:\\x1b[56;6u"
        "ctrl+digit_9=text:\\x1b[57;6u"
        "ctrl+9=text:\\x1b[57;6u"

        # cmd+up/down cycles herdr agents (replaces built-in jump_to_prompt)
        "cmd+arrow_up=text:\\x1b[32;5ua"
        "cmd+arrow_down=text:\\x1b[32;5uA"

        # cmd+d/cmd+shift+d split *herdr* panes (not ghostty's own panes) via
        # herdr's default split_vertical=prefix+v / split_horizontal=prefix+minus.
        # cmd+option+arrows moves focus between herdr panes via the default
        # focus_pane_left/down/up/right=prefix+h/j/k/l. No herdr [keys]
        # overrides needed here since these all target herdr's own defaults.
        "cmd+d=text:\\x1b[32;5uv"
        "cmd+shift+d=text:\\x1b[32;5u-"
        "cmd+alt+arrow_left=text:\\x1b[32;5uh"
        "cmd+alt+arrow_down=text:\\x1b[32;5uj"
        "cmd+alt+arrow_up=text:\\x1b[32;5uk"
        "cmd+alt+arrow_right=text:\\x1b[32;5ul"
      ];
      shell-integration-features = "ssh-terminfo,ssh-env,sudo";

      link-url = true;

      mouse-hide-while-typing = true;
      copy-on-select = "clipboard";
      clipboard-trim-trailing-spaces = true;
      focus-follows-mouse = true;
    };
  };
}
