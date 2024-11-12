{
  description = "Deterministic Typst compilation with Nix";

  nixConfig = {
    extra-substituters = ["https://typst-nix.cachix.org"];
    extra-trusted-public-keys = ["typst-nix.cachix.org-1:OzDUMt0nd4wlI1AHucBPnchl4utWXeFTtUFt8XZ3DbA="];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      flake = {
        overlays.default = _final: _prev: {};
        templates = rec {
          default = quick-start;
          quick-start = {
            description = "A Typst project";
            path = ./examples/quick-start;
          };
        };
      };

      perSystem = {
        pkgs,
        lib,
        ...
      }: let
        mkReleaseScript = pkgs.callPackage ./release.nix {};
      in {
        formatter = pkgs.alejandra;

        # TODO: Write checks
        #checks = import ./checks { inherit pkgs; myLib = typstLib; };

        packages = pkgs.callPackage ./pkgs.nix {};

        apps = {
          release = {
            type = "app";
            program = lib.getExe mkReleaseScript;
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            alejandra
            markdownlint-cli
            mdbook
            nodePackages.prettier
          ];
        };
      };
    };
}
