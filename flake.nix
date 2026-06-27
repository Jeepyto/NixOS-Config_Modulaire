{
  description = "NixOS jeepy";
  inputs = {
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trcc-linux.url = "github:Lexonight1/thermalright-trcc-linux";
  };
  outputs = { self, nixpkgs, nix-cachyos-kernel, trcc-linux,... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.overlays = [
            nix-cachyos-kernel.overlays.pinned
          ];
        }
        trcc-linux.nixosModules.default
        ./hardware-configuration.nix
        ./modules
        ./lib     
      ];
    };
  };
}
