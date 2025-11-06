{ flakeInputs, lib, ... }: {
	vim = {
		debugMode = {
			enable = false;
			level = 16;
			logFile = "/tmp/nvim.log";
		};

		lsp = {
			# This must be enabled for the language modules to hook into
			# the LSP API.
			enable = true;

			# formatOnSave = true;
			lspkind.enable = true;
			trouble.enable = true;
			lspSignature.enable = true;
			otter-nvim.enable = true;

			mappings = {
				goToDefinition = "M";
				hover = "mm";
				renameSymbol = "<leader>c";
			};
		};

		# This section does not include a comprehensive list of available language modules.
		# To list all available language module options, please visit the nvf manual.
		languages = {
			enableFormat = true;
			enableTreesitter = true;
			enableExtraDiagnostics = true;

			# Languages that will be supported in default and maximal configurations.
			nix = {
				enable = true;
				extraDiagnostics.types = [ "deadnix" ];
			};
			markdown.enable = true;

			# Languages that are enabled in the maximal configuration.
			bash.enable = true;
			clang.enable = true;
			sql.enable = true;
			go.enable = true;
			python.enable = true;
		};

		visuals = {
			fidget-nvim.enable = true;
		};

		statusline = {
			lualine = {
				enable = true;
				theme = "ayu_dark";
			};
		};

		lazy.plugins = {
			ayu = {
				package = flakeInputs.ayu // { name = "ayu"; };
				lazy = false;
				after = ''vim.cmd("colorscheme ayu")'';
			};

			leap-nvim = {
				package = "leap-nvim";
				keys = [
					{
						desc = "Jump with vim leap";
						mode = [ "n" "x" "o" ];
						key = "s";
						action = "<Plug>(leap-anywhere)";
					}
				];
			};
			undotree = {
				package = "undotree";
				keys = [
					{
						desc = "Open UndoTree";
						mode = "";
						key = "<leader>u";
						action = "<cmd>UndotreeToggle<CR>";
					}
				];
				cmd = [ "UndotreeToggle" ];
				beforeAll = /* lua */ ''
					vim.opt.undofile = true
					vim.opt.backup = false
					vim.opt.writebackup = false
				'';
			};
		};
		autocomplete = {
			nvim-cmp = {
				enable = true;
				mappings = {
					next = "<C-n>";
					previous = "<C-e>";
					scrollDocsDown = "<M-n>";
					scrollDocsUp = "<M-e>";
					close = "<C-i>";
				};
			};
		};

		augroups = [
			{ name = "rnuToggle"; }
		];

		autocmds = [
			{
				desc = "Highlight on yank";
				event = [ "TextYankPost" ];
				callback = lib.generators.mkLuaInline /* lua */''
					function ()
						vim.hl.on_yank({ timeout = 300 })
					end
				'';
			}
			{
				desc = "Trim whitespace";
				event = [ "BufWritePre" ];
				callback = lib.generators.mkLuaInline /* lua */''
					function ()
						local save = vim.fn.winsaveview()
						vim.api.nvim_command([[keeppatterns silent %s/\\\@<!\s\+$//e]])
						vim.fn.winrestview(save)
					end
				'';
			}
			{
				group = "rnuToggle";
				desc = "[rnuToggle] Enable";
				event = [ "BufEnter" "FocusGained" "InsertLeave" ];
				callback = lib.generators.mkLuaInline /* lua */''
					function ()
						vim.opt.relativenumber = true
					end
				'';
			}
			{
				group = "rnuToggle";
				desc = "[rnuToggle] Disable";
				event = [ "BufLeave" "FocusLost" "InsertEnter" ];
				callback = lib.generators.mkLuaInline /* lua */''
					function ()
						vim.opt.relativenumber = false
					end
				'';
			}
		];

		snippets.luasnip.enable = true;

		treesitter.context.enable = true;

		binds = {
			whichKey.enable = true;
		};

		notes = {
			todo-comments.enable = true;
		};

		ui = {
			borders.enable = true;
			colorizer.enable = true;
			illuminate.enable = true;
		};

		comments = {
			comment-nvim = {
				enable = true;
				mappings = {
					toggleCurrentLine = "<M-/>";
					toggleSelectedLine = "<M-/>";
				};
			};
		};

		options = {
			# Misc
			mouse = "a";
			hlsearch = false;
			scrolloff = 5;

			# Indent
			expandtab = false;
			copyindent = true;
			preserveindent = true;
			softtabstop = 0;
			shiftwidth = 3;
			tabstop = 3;

			# Visual spaces
			list = true;
			listchars = "tab:  ,trail:~,eol: ,extends: ";
			showbreak = ">==>";
			linebreak = true;

			# Cmds
			ignorecase = true;
			smartcase = true;
			inccommand = "nosplit";
		};
	};
}
