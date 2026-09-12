{
  self,
  home-manager,
}:

{ config, lib, pkgs, ... }:
let
  cfg = config.programs.gnuapl;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
in
{
  options.programs.gnuapl = {
    enable = mkEnableOption "GNU APL interpreter";
    package = mkOption {
      type = lib.types.package;
      default = self.packages."${pkgs.stdenv.hostPlatform.system}".default;
      defaultText = lib.literalExpression "gnuapl-flake.packages.${pkgs.stdenv.hostPlatform.system}.default";
      description = "Package to use for GNU APL. Set as null to disable.";
    };
    keyboardLayout = mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "us";
      description = "Keyboard layout for GNU APL. Set as null to disable. The layout must be installed on the system.";
    };
  };

  config = mkIf cfg.enable {
    warnings = lib.lists.optional (cfg.keyboardLayout == null) "Keyboard layout is not set, GNU APL may not work properly.";

    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    home.keyboard = mkIf (cfg.keyboardLayout != null) {
      layout = lib.strings.join "," [ cfg.keyboardLayout "apl" ];
      variant = ",dyalog";
      options = "grp:switch";
    };
  };
}
