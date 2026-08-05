# System-level shell plumbing. The actual zsh config (oh-my-zsh, theme,
# plugins) lives in modules/home/shell.nix — this just does the two things
# that have to happen system-wide: register zsh as a valid login shell, and
# make sure an ssh client + agent exist.
{
  flake.nixosModules.core-shell =
    { pkgs, ... }:
    {
      programs.zsh.enable = true; # adds zsh to /etc/shells so it's a valid `users.users.<name>.shell`

      programs.ssh.startAgent = true; # ssh-agent as a per-session systemd user service

      # gcr-ssh-agent (GNOME's keyring-integrated ssh-agent) defaults to
      # "on" as soon as gnome-keyring is enabled (see
      # modules/nixos/desktop/niri.nix), and NixOS refuses to evaluate if
      # it's on at the same time as `programs.ssh.startAgent` — only one
      # ssh-agent can own the socket. We want the plain openssh one above
      # (paired with home-manager's `programs.ssh.addKeysToAgent`), so this
      # loses.
      services.gnome.gcr-ssh-agent.enable = false;

      environment.systemPackages = [
        pkgs.openssh # ssh/scp/sftp/ssh-keygen (not in the default package set)
        pkgs.nano # simple system-wide editor for quick edits (e.g. as root)
      ];
    };
}
