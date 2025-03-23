{
  description = "The host flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
  };

  outputs = 
    {
      self,
      nixpkgs,
      systems 
    }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      templates = {
        default = {
          description = "a template";
          path = ./templates/default;
          welcomeText = ''
            Welcome to the default template
          '';
        };
      };
      # necessary to pass CI; there needs to be at least one per-system output
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.hello;
      });
    };
}
