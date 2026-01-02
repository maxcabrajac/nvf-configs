{
	description = "Neovim nvf-based config";
	inputs = {
		systems.url = "github:nix-systems/default";
		nixpkgs.follows = "nvf/nixpkgs";

		flake-parts = {
			url = "github:hercules-ci/flake-parts";
			inputs.nixpkgs-lib.follows = "nixpkgs";
		};

		nvf = {
			url = "github:NotAShelf/nvf";
			inputs = {
				flake-parts.follows = "flake-parts";
				systems.follows = "systems";
			};
		};
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
				extractAndRenameMainBin = name: p: pkgs.linkFarm name [ { name = "bin/${name}"; path = lib.getExe p; } ];
			in
				lib.foldr (a: b: a // b) {} [
					nvims
					(lib.mapAttrs' (name: p: { name = name + "-wrapped"; value = extractAndRenameMainBin name p; }) nvims)
					{ default = nvims.editor; }
				]
			;
		};
	};
}
