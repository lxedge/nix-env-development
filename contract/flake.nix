{
  description = "Personal Contract Development";

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
      in
      {
        devShells.dev-contract = pkgs.mkShell {
          packages = with pkgs; [
            libiconv
            gnumake
            git
            jq
            zsh

            go
            gotools
            gopls
            delve
            gdlv
            golangci-lint
            gofumpt
            grpcurl
            goctl
            protobuf
            protoc-gen-doc
            protoc-gen-go
            protoc-gen-go-grpc

            nodejs_24
            typescript
            typescript-language-server
            prettier
            eslint
            pnpm
            yarn
            solc
            vscode-solidity-server
            foundry
          ];
        };

        shell = "${pkgs.zsh}/bin/zsh";
        shellHook = "";
      }
    );
}
