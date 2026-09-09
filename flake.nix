{
  description = "Flake for GNU APL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

    forAllSystems = systems: perSystem:
      builtins.foldl' (acc: system:
        let
          perSystem' = perSystem system nixpkgs.legacyPackages."${system}";
        in
        (builtins.mapAttrs (name: value:
          (acc."${name}" or {}) // { "${system}" = value; }
        ) perSystem')
      ) {} systems;
  in
  {
    homeModules = {
      default = import ./hm-modules {
        inherit self home-manager;
      };
    };
  }
  //
  forAllSystems supportedSystems (system: pkgs:
    let
      gnuapl = pkgs.callPackage ./package.nix {};
      gnuapl-minimum = pkgs.callPackage ./package.nix { minimum-gnuapl-build = true; };
    in
    {
      packages = {
        default = gnuapl;
        gnuapl = gnuapl;
        gnuapl-minimum = gnuapl-minimum;
      };
    }
  );
}
