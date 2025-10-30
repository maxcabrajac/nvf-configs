{
	description = "Neovim nvf-based config";
	inputs = {
		systems.url = "github:nix-systems/default";
		flake-parts = {
			url = "github:hercules-ci/flake-parts";
			inputs.nixpkgs-lib.follows = "nixpkgs";
		};

		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nvf.url = "github:NotAShelf/nvf/v0.8";
		ayu = { url = "github:Luxed/ayu-vim"; flake = false; };
	};
	outputs = { flake-parts, self, ... } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } {
		systems = import inputs.systems;
		perSystem = { pkgs, lib, ... }: {
			packages = let
				nvfLib = inputs.nvf.lib;

				modulesPerPackage = rec {
					base = [
						{ _module.args = { flakeInputs = inputs; };  }
						./keybinds.nix
					];
					editor = base ++ [
						./config.nix
					];
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
				renameBin = name: p: pkgs.writers.writeDashBin name ''${lib.getExe p}'';
			in
				lib.fold (a: b: a // b) {} [
					nvims
					(lib.mapAttrs' (name: p: { name = name + "-wrapped"; value = renameBin name p; }) nvims)
					{ default = nvims.editor; }
				]
			;
		};
	};
}
