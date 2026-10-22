# Go and Python toolchains. Kept separate from dev-tools.nix (editor/git/k8s
# tooling) since this file is about language runtimes and is the natural
# place to add more languages later.
{
  flake.homeModules.dev-langs-user =
    { pkgs, ... }:
    {
      home.packages = [
        # Go
        pkgs.go
        pkgs.gopls # language server, for editor integration (vscode, etc.)
        pkgs.golangci-lint
        pkgs.delve # debugger

        # Python
        pkgs.python3
        pkgs.uv # fast pip/venv/project manager; handles per-project interpreters and deps
        pkgs.ruff # linter + formatter
        pkgs.python3Packages.python-lsp-server
      ];

      # Go env vars normally set by `go env -w`; setting them here keeps
      # GOPATH/GOBIN out of $HOME/go's default and off the Nix store path,
      # and puts GOBIN on PATH so `go install`ed binaries are runnable.
      home.sessionVariables = {
        GOPATH = "$HOME/.local/share/go";
        GOBIN = "$HOME/.local/share/go/bin";
      };
      home.sessionPath = [ "$HOME/.local/share/go/bin" ];
    };
}
