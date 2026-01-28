{
  description = "KuWeb3 Backend Full Go Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      private_repo = "bitbucket.kucoin.net";

      # --- Custom Go 1.24.6 ---
      go_1246 = pkgs.go_1_24.overrideAttrs (_: rec {
        version = "1.24.6";
        src = pkgs.fetchurl {
          url = "https://go.dev/dl/go${version}.src.tar.gz";
          hash = "sha256-4ctVgqq1iGaLwEwH3hhogHD2uMmyqvNh+CHhm9R8/b0=";
        };
      });

      goShellHook = ''
        export GOPATH=$HOME/go
        export PATH=$GOPATH/bin:$PATH
        export PATH="${pkgs.protobuf}/bin:$PATH"

        go env -w GOPRIVATE="${private_repo}"
        go env -w GONOSUMDB="${private_repo}"

        if [ -d .git ]; then
           git config core.hooksPath .githooks
           echo "Git hooks configured: .githooks"
        fi

        echo "--------------------------------------------------------------------------------"
        echo "-- Backend Full Go Environment Loaded"
        echo "-- go:                 $(which go)"
        echo "-- goctl:              $(which goctl)"
        echo "-- protoc:             $(which protoc)"
        echo "-- protoc-gen-go:      $(which protoc-gen-go)"
        echo "-- protoc-gen-go-grpc: $(which protoc-gen-go-grpc)"
        echo "-- GOPRIVATE:          $(go env GOPRIVATE)"
        echo "--------------------------------------------------------------------------------"
      '';
    in
    {
      devShells.backend-full = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Go
          go_1246
          gotools gopls go-tools delve
          golangci-lint gofumpt

          # Protobuf
          protobuf protoc-gen-go protoc-gen-go-grpc grpcurl

          # KuCoin tool
          goctl

          # Utilities
          direnv nix-direnv
          just
          zellij
          gnumake42
          libgcc
        ];

        shell = "${pkgs.zsh}/bin/zsh";
        shellHook = goShellHook;
      };
    });
}
