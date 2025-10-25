{
	description = "Neovim nvf-based config";
	inputs = {
		systems.url = "github:nix-systems/default";
		flake-parts = {
			url = "github:hercules-ci/flake-parts";
			inputs.nixpkgs-lib.follows = "nixpkgs";
		};

		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nvf.url = "github:NotAShelf/nvf";
	};
	outputs = { flake-parts, self, ... } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } {
		# Allow users to bring their own systems.
		# «https://github.com/nix-systems/nix-systems»
		systems = import inputs.systems;

		perSystem = { pkgs, lib, ... }: {
			packages = let
				nvfLib = inputs.nvf.lib;

				modulesPerPackage = rec {
					base = [
						./keybinds.nix
					];
					editor = base ++ [];
					pager = base ++ [];
				};

				mkNvim = modules: let
					config = nvfLib.neovimConfiguration {
						inherit pkgs modules;
					};
				in
					config.neovim
				;
				nvims = builtins.mapAttrs (_: mkNvim) modulesPerPackage;
			in
				nvims // { default = nvims.editor; }
			;
		};
	};
}
