{
  description = "flake for simple go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        goShellHook = ''
          export GOPATH=$HOME/go
          export PATH=$GOPATH/bin:$PATH
          echo "-- go: $(which go)"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools
            delve

            direnv
            nix-direnv
          ];

          shell = "${pkgs.zsh}/bin/zsh";
          shellHook = goShellHook;
        };
      }
    );
}
