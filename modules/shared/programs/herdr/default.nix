{ ... }:
{
  imports = [ ./plugins.nix ];

  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [theme]
    name = "catppuccin"
    auto_switch = false

    [ui]
    prompt_new_tab_name = false

    [ui.toast]
    delivery = "terminal"

    [keys]
    prefix = "ctrl+space"
    new_tab = "prefix+t"
    rename_tab = "prefix+shift+,"
    close_tab = "prefix+shift+w"
    new_workspace = "prefix+n"
    rename_workspace = "prefix+shift+n"
    next_workspace = "ctrl+tab"
    previous_workspace = "ctrl+shift+tab"
    next_tab = "ctrl+alt+tab"
    previous_tab = "ctrl+alt+shift+tab"
    next_agent = "prefix+a"
    previous_agent = "prefix+shift+a"

    [keys.indexed]
    tabs = "alt"
    workspaces = "ctrl+shift"

    [[keys.command]]
    key = "ctrl+f"
    type = "plugin_action"
    command = "herdr-float.toggle"
    description = "Toggle floating shell"

    [[keys.command]]
    key = "prefix+g"
    type = "plugin_action"
    command = "herdr-lazygit.open"
    description = "lazygit: open in a split"

    [[keys.command]]
    key = "prefix+shift+g"
    type = "plugin_action"
    command = "herdr-lazygit.open-tab"
    description = "lazygit: open in its own tab"

    [[keys.command]]
    key = "prefix+shift+t"
    type = "plugin_action"
    command = "fullerzz.sesh.open-picker"
    description = "open Sesh picker"

    [[keys.command]]
    key = "prefix+shift+b"
    type = "plugin_action"
    command = "fullerzz.sesh.last"
    description = "switch to previous Sesh workspace"
  '';
}
