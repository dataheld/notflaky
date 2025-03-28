{
  description = "The host flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-checker.url = "github:DeterminateSystems/flake-checker";
    flake-iter.url = "github:DeterminateSystems/flake-iter";
  };

  outputs = { self, nixpkgs, flake-iter, flake-checker }:
    let
      
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      checks = forEachSupportedSystem ({ pkgs}: {
        test-template-bad-readme =
          pkgs.runCommand "test-bad-readme"
            {
              buildInputs = [
                pkgs.nix
              ];
              __noChroot = true;
              NIX_CONFIG = "experimental-features = nix-command flakes";
            }
            ''
              mkdir -p $TMPDIR/home
              export HOME=$TMPDIR/home
              # cd $tmp
              nix flake init --template ${self}#default
              echo "bad _markdown*" > README.md
              if ! nix flake check; then
                touch $out
              else
                echo "Test failed: nix flake check succeeded unexpectedly"
                exit 1
              fi
            '';
        test-template-good-readme =
              pkgs.runCommand "test-good-readme"
                {
                  buildInputs = [
                    pkgs.nix
                  ];
                  __noChroot = true;
                  NIX_CONFIG = "experimental-features = nix-command flakes";
                }
                ''
                  mkdir -p $TMPDIR/home
                  export HOME=$TMPDIR/home
                  # cd $tmp
                  nix flake init --template ${self}#default
                  echo "good *markdown*" > README.md
                  if nix flake check; then
                    touch $out
                  else
                    echo "Test failed: nix flake check failed unexpectedly"
                    exit 1
                  fi
                '';
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
            flake-iter.packages.${system}.default
            flake-checker.packages.${system}.default
          ];
        };
      });
      templates = {
        default = {
          description = "a template";
          path = ./templates/default;
          welcomeText = ''
            Welcome to the default template
          '';
        };
      };
    };
}
