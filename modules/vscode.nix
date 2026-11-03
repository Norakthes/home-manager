{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {

      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.debugpy

        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow

        ms-python.black-formatter
        ms-python.isort
        ms-python.flake8

        ms-python.vscode-pylance

        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        ms-vscode.makefile-tools
        llvm-vs-code-extensions.vscode-clangd

        vscodevim.vim
        vadimcn.vscode-lldb

        james-yu.latex-workshop

        wgsl-analyzer.wgsl-analyzer

        ms-python.vscode-python-envs
        ms-vscode.cmake-tools
        ms-azuretools.vscode-docker
        ms-azuretools.vscode-containers
        ziglang.vscode-zig
        sumneko.lua
        denoland.vscode-deno
        platformio.platformio-vscode-ide

        anthropic.claude-code
        github.copilot-chat

        zhuangtongfa.material-theme
        github.github-vscode-theme
      ];

      userSettings = {
        "workbench.colorTheme" = "One Dark Pro";
        "terminal.integrated.stickyScroll.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "newWindow";

        "claudeCode.preferredLocation" = "panel";
        "github.copilot.nextEditSuggestions.eagerness" = "low";
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = false;
          "scminput" = false;
          "html" = true;
        };
        "chat.mcp.gallery.enabled" = true;
        "chat.planAgent.defaultModel" = "Claude Haiku 4.5 (copilotcli)";

        "python.terminal.activateEnvironment" = true;

        "python.venvPath" = ".venv";
        "python.terminal.activateEnvInCurrentTerminal" = true;

        "jupyter.askForKernelRestart" = false;
        "jupyter.interactiveWindow.creationMode" = "perFile";
        "jupyter.notebookFileRoot" = "\${workspaceFolder}";

        "python.experiments.enabled" = false;
        "python.experiments.optInto" = [];

        "python.createEnvironment.trigger" = "off";
        "python.analysis.typeCheckingMode" = "basic";
        "python.formatting.provider" = "black";
        "[python]" = {
          "editor.formatOnSave" = false;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = "never";
          };
          "editor.defaultFormatter" = "ms-python.black-formatter";
        };

        "terminal.integrated.env.linux" = {
          "UV_CACHE_DIR" = "\${userHome}/.cache/uv";
        };

        "C_Cpp.autocomplete" = "disabled";
        "C_Cpp.intelliSenseEngine" = "disabled";
        "clangd.enable" = true;
        "makefile.configureOnOpen" = true;

        "zig.zls.enabled" = "on";
        "zig.buildOnSaveProvider" = "off";
        "[zig]" = {
          "editor.wordSeparators" = "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?";
        };
      };
    };
  };
}
