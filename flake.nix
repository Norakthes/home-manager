{
  description = "Rasmus' home-manager config (standalone, works on any Linux)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    st.url = "github:norakthes/st-flake";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ (import ./packages) ];
      config = {
        allowUnfree = true;
        # Marked broken ahead of its removal, but lutris' FHS env still has it
        problems.handlers."gtk+".broken = "warn";
      };
    };

    # One home per host: modules/core.nix plus hosts/<host>, which imports
    # whatever optional modules that machine wants.
    mkHome = host: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        inputs.nixvim.homeModules.nixvim
        ./modules/core.nix
        ./hosts/${host}
      ];
    };
  in
  {
    # home-manager switch --flake .   (picks rasmus@$(hostname))
    homeConfigurations = {
      "rasmus@fedora" = mkHome "fedora";
      "rasmus@laptop" = mkHome "laptop";
      "rasmus@desktop" = mkHome "desktop";
    };

    packages.${system} = {
      inherit (pkgs) maple dwmstatus;
    };
  };
}
