{ config, pkgs, nixpkgs-unstable, ... }:

{

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays = [
      (final: prev: {
        unstable = import nixpkgs-unstable {
          system = "${prev.system}";
          config.allowUnfree = true;
        };
      })
    ];
  };
}
