{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # or a specific revision
    home-manager.url = "github:nix-community/home-manager/release-23.11"; # adjust the branch
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (self: super: {
            # Example: overriding Alacritty with a specific version
            alacritty = super.alacritty.overrideAttrs (oldAttrs: {
              src = super.fetchFromGitHub {
                owner = "alacritty";
                repo = "alacritty";
                # This is the commit hash of the version you want to use
                rev = "b8acfdae1936fbdc8745fd5d9269b546a4bb9b0f";
                # Get the sha256 from the source using something like this: nix-prefetch-url --unpack https://github.com/alacritty/alacritty/archive/b8acfdae1936fbdc8745fd5d9269b546a4bb9b0f.tar.gz
                sha256 = "1hmfpznnz6h6g753w6239az5rn9af3260lciz3nvpbqcg275ms78";
              };
            });
          })
        ];  # Add your overlays here
        username = "rbmenke";
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        homeManagerConfiguration = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          system = system;
          # Define the username that will be managed by Home Manager
          username = "rbmenke";
          homeDirectory = "/home/${username}";
          configuration = { config, pkgs, ... }: {
            imports = [ ];
            home.packages = with pkgs; [
              alacritty  # Here you might specify the version or use an overlay
            ];
          };
        };
      in
      {
        homeManagerConfigurations = {
          my-user = homeManagerConfiguration;
        };
      }
    );
}
