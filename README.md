
# after fresh install linux

> NOTE: personal and oppionated setup
> FYI: kate is my default txt and markdown editor
> this setup separated into: 
> > general tasks, debian-based, and arch-based tasks

## general tasks

> we need to generalized `after fresh install` tasks
> prefer default config, anti-maxxing configuration
> less apps on the dock, only essentials
> minimal apps customization to simplify regular installation

- install homebrew package manager

> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
> brew install zig
> brew install dotnet

- browser of choice: floorp (firefox based with vertical tabs and more)

```bash
curl -fsSL https://ppa.floorp.app/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/Floorp.gpg
sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list 'https://ppa.floorp.app/Floorp.list'
sudo apt update
sudo apt install floorp
```

- christitus linux utility 

> curl -fsSL https://christitus.com/linux | sh

- kitty terminal (no tmux, just tabs), evince, onlyoffice
- install browser of choice: zen and brave (via flathub by chris' utils )

> brew install tldr gcc nushell neovim
> brew install fzf bat ropgrep
> brew install uv

- install nvm (node version manager) and pnpm 

> curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

> curl -fsSL https://bun.sh/install | bash
or
> curl -fsSL https://get.pnpm.io/install.sh | sh -


- rust toolkits

> brew install rustup
> rustup install stable

- daily needs 

> pnpm i -g md-to-pdf
> pnpx puppeteer browsers install chrome



---

## debian-based only

- remove bloats `sudo apt remove libreoffice-*`

> sudo apt install snapd 
> snap install ghostty --classic

> sudo apt install vim vlc
> apt remove firefox-esr # or others built-in browser

- important management 

> sudo apt install baobab ncdu 

---

## arch-based only 

TODO

---

@naranyala






