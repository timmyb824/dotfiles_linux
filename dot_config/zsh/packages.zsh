# --- pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# --- fzf ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# --- other ---
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"
eval "$(fnm env --use-on-cd)"
eval "$(basher init - zsh)"
eval "$(kickstart infect)"
eval "$(rbenv init - zsh)"

source "$HOME/.config/broot/launcher/bash/br"


