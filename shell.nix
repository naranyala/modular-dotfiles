# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ 
    pkgs.git 
    pkgs.bash
    pkgs.starship 
  ];

  shellHook = ''
    ## autorun
    eval "$(starship init bash)"

    ## aliases
    alias gs='git status'
    alias ll='ls -l --color=auto'
    alias md2pdf='bun run /run/media/root/Data/diskd-bun-script/dotfiles/scripts-js/convert-markdown2pdf-batch.js'


    ## git-aware
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      echo "✅ Inside a Git repo: $(git rev-parse --show-toplevel)"
      echo "📦 Current branch: $(git rev-parse --abbrev-ref HEAD)"
    else
      echo "⚠️ Not inside a Git repository."
    fi
  '';

}

