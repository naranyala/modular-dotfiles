# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ pkgs.git pkgs.bash ];

  shellHook = ''
    alias gs='git status'
    alias ll='ls -l --color=auto'
    echo "Aliases loaded: gs, ll"
  '';
}

