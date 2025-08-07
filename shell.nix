# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ 
    pkgs.git 
    pkgs.bash
    pkgs.bashInteractive
    pkgs.starship 
  ];

  shellHook = ''
    ## load .env
    ENV_PATH=~/projects-remote/modular-dotfiles/.env

    set -a
    source $ENV_PATH
    set +a
    echo "✅ Loaded .env variables"

    ## autorun
    eval "$(starship init bash)"

    ## aliases
    alias gs='git status'
    alias ll='ls -l --color=auto'
    alias md2pdf="bun run $DISKD_SCRIPT_DIR/convert-markdown2pdf-batch.js"


    ## git-aware
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      echo "✅ Inside a Git repo: $(git rev-parse --show-toplevel)"
      echo "📦 Current branch: $(git rev-parse --abbrev-ref HEAD)"
    else
      echo "⚠️ Not inside a Git repository."
    fi
  '';

}

