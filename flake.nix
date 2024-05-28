{
  description = "suimong's Nix repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  
  outputs = inputs @ { self, nixpkgs, flake-parts, systems }: 
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;
      flake = {
        # nixosModules = nixpkgs.lib.mapAttrs (_: path: import path) (import ./modules) // {
        #   default = {
        #     imports = nixpkgs.lib.attrValues self.nixosModules;
        #   };
        # };

        # overlays = import ./overlays // {
        #   pkgs = _: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
        #   default = _: _: { xeals = nixpkgs.lib.composeExtensions self.overlays.pkgs; };
        # };
      };
      perSystem = {pkgs, ... }: {
          packages = import ./pkgs/top-level;

          formatter = pkgs.nixfmt-rfc-style;

          # checks = {
          #   # Ensures that the NUR bot can evaluate and find all our packages.
          #   # Normally we'd also run with `--option restrict-eval true`, but
          #   # this is incompatible with flakes because reasons.
          #   nur = pkgs.writeShellScriptBin "nur-check" ''
          #     # Prefer nixpkgs channel (actual build), otherwise read from flake.lock (CI)
          #     if ! nixpkgs=$(nix-instantiate --find-file nixpkgs 2>/dev/null); then
          #       _rev=$(${pkgs.jq}/bin/jq -r .nodes.nixpkgs.locked.rev flake.lock)
          #       nixpkgs="https://github.com/nixos/nixpkgs/archive/''${_rev}.tar.gz"
          #     fi
          #     nix-env -f . -qa \* --meta \
          #       --allowed-uris https://static.rust-lang.org \
          #       --option allow-import-from-derivation true \
          #       --drv-path --show-trace \
          #       -I nixpkgs="$nixpkgs" \
          #       -I ./ \
          #       --json | ${pkgs.jq}/bin/jq -r 'values | .[].name'
          #   '';
          # };

          # devShells.ci = pkgs.mkShellNoCC {
          #   buildInputs = [ pkgs.nix-build-uncached ];
          # };

      };
    };
}