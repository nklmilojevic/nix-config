{
  lib,
  ...
}:
let
  pluginsDir = ./plugins;
  plugins = builtins.attrNames (builtins.readDir pluginsDir);
in
{
  home.file = lib.genAttrs (map (name: ".swiftbar-plugins/${name}") plugins) (
    target:
    let
      name = lib.removePrefix ".swiftbar-plugins/" target;
    in
    {
      source = pluginsDir + "/${name}";
      executable = true;
    }
  );
}
