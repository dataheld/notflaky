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
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
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
    };
}
