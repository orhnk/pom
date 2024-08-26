{
  # REFERENCE: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/misc/porsmo/default.nix
  description = "A flake for the Rust package pom";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Adjust the channel as needed
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [];
        };
        rustPackage = pkgs.rustPlatform.buildRustPackage rec {
          pname = "pom";
          version = "0.3.0";

          src = ./.;

          cargoHash = "sha256-vv8n9qiPCrFnDADW1mi3bLTTyuyf63rZ/ZKd61OApug=";

          nativeBuildInputs = [
            pkgs.pkg-config
            # pkgs.rustPlatform.bindgenHook
          ];

          buildInputs =
            [
              pkgs.alsa-lib
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.CoreAudio
              pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            ];

          passthru.tests.version = pkgs.testers.testVersion {
            package = rustPackage; # Updated reference to the package variable
          };

          meta = with pkgs.lib; {
            description = "Pomodoro cli app in rust with timer and countdown";
            homepage = "https://github.com/ColorCookie-dev/porsmo"; # Assuming the homepage remains unchanged
            license = licenses.mit;
            maintainers = with maintainers; [MoritzBoehme];
            mainProgram = "pom"; # Updated main program name
          };
        };
      in {
        packages.pom = rustPackage; # Updated package name in the flake output
        defaultPackage = rustPackage;
      }
    );
}
