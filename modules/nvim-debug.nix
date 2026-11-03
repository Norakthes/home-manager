# Debugging in nvim through DAP (gdb or lldb). Layout while debugging:
#
#   +-------------+------------------+
#   |             | scopes / watches |
#   |    code     +------------------+
#   |             | gdb / lldb repl  |
#   +-------------+------------------+
#
# The ui opens on session start and closes when it ends. In the repl, gdb
# commands go straight through; with lldb prefix them with a backtick.
# rizin has no DAP, :Rizin <args> runs it in a terminal in the same spot.
{ pkgs, lib, ... }:
let
  askProgram = {
    __raw = ''
      function()
        return vim.fn.input("Program: ", vim.fn.getcwd() .. "/", "file")
      end
    '';
  };

  launch = adapter: {
    name = "Launch (${adapter})";
    type = adapter;
    request = "launch";
    program = askProgram;
    cwd = "\${workspaceFolder}";
    stopAtBeginningOfMainSubprogram = false;
  };

  attach = adapter: {
    name = "Attach to process (${adapter})";
    type = adapter;
    request = "attach";
    pid.__raw = ''require("dap.utils").pick_process'';
  };

  nativeConfigs = [
    (launch "gdb")
    (launch "lldb")
    (attach "gdb")
    (attach "lldb")
  ];
in
{
  home.packages = with pkgs; [
    gdb
    lldb
    rizin
  ];

  programs.nixvim = {
    plugins.dap = {
      enable = true;

      adapters.executables = {
        gdb = {
          command = lib.getExe' pkgs.gdb "gdb";
          args = [ "--interpreter=dap" "--eval-command" "set print pretty on" ];
        };
        lldb.command = lib.getExe' pkgs.lldb "lldb-dap";
      };

      configurations = {
        c = nativeConfigs;
        cpp = nativeConfigs;
        rust = nativeConfigs;
        zig = nativeConfigs;
      };

      signs = {
        dapBreakpoint = { text = "●"; texthl = "DiagnosticError"; };
        dapBreakpointCondition = { text = "◆"; texthl = "DiagnosticWarn"; };
        dapStopped = { text = "▶"; texthl = "DiagnosticOk"; linehl = "Visual"; };
      };
    };

    plugins.dap-ui = {
      enable = true;
      settings.layouts = [
        {
          position = "right";
          size = 80;  # columns
          elements = [
            { id = "scopes"; size = 0.35; }
            { id = "watches"; size = 0.15; }
            { id = "repl"; size = 0.5; }
          ];
        }
      ];
    };

    plugins.dap-virtual-text.enable = true;

    keymaps = [
      { mode = "n"; key = "<F5>"; action.__raw = ''function() require("dap").continue() end''; options.desc = "Debug: start/continue"; }
      { mode = "n"; key = "<F10>"; action.__raw = ''function() require("dap").step_over() end''; options.desc = "Debug: step over"; }
      { mode = "n"; key = "<F11>"; action.__raw = ''function() require("dap").step_into() end''; options.desc = "Debug: step into"; }
      { mode = "n"; key = "<F12>"; action.__raw = ''function() require("dap").step_out() end''; options.desc = "Debug: step out"; }
      { mode = "n"; key = "<leader>b"; action.__raw = ''function() require("dap").toggle_breakpoint() end''; options.desc = "Toggle breakpoint"; }
      { mode = "n"; key = "<leader>B"; action.__raw = ''function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end''; options.desc = "Conditional breakpoint"; }
      { mode = "n"; key = "<leader>dc"; action.__raw = ''function() require("dap").run_to_cursor() end''; options.desc = "Debug: run to cursor"; }
      { mode = "n"; key = "<leader>dt"; action.__raw = ''function() require("dap").terminate() end''; options.desc = "Debug: stop"; }
      { mode = "n"; key = "<leader>du"; action.__raw = ''function() require("dapui").toggle() end''; options.desc = "Debug: toggle ui"; }
      { mode = "n"; key = "<leader>dw"; action.__raw = ''function() require("dapui").elements.watches.add(vim.fn.expand("<cexpr>")) end''; options.desc = "Debug: watch expression under cursor"; }
      { mode = [ "n" "v" ]; key = "<leader>de"; action.__raw = ''function() require("dapui").eval() end''; options.desc = "Debug: evaluate"; }
    ];

    extraConfigLua = ''
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized.dapui = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui = function() dapui.close() end
      dap.listeners.before.event_exited.dapui = function() dapui.close() end

      vim.api.nvim_create_user_command("Rizin", function(opts)
        local args = opts.args ~= "" and opts.args or vim.fn.input("rizin ", "-A ", "file")
        vim.cmd("botright vsplit")
        vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.4))
        vim.cmd.terminal("rizin " .. args)
        vim.cmd.startinsert()
      end, { nargs = "*", complete = "file", desc = "Open rizin in a right-hand terminal" })
    '';
  };
}
