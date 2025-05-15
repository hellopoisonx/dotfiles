alias vim="nvim"
alias ssh="kitten ssh"
alias icat="kitten icat"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
export EDITOR=nvim
export PATH="$PATH:$HOME/.local/bin"
eval "$(starship init zsh)"

# initialize autocompletion
autoload -U compinit && compinit

# history setup
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST

function history_fzf() {
    eval "$(history 0 | fzf | awk '{print $2}')"
}

zle -N history_fzf

function load_keybind() {
    bindkey '^H' history_fzf
}

# plugins

source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
    load_keybind
}

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

## must be at the tail of .zshrc
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/hpxx/.dart-cli-completion/zsh-config.zsh ]] && . /home/hpxx/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

