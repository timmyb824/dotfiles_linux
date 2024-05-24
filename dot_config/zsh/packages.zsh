# --- pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# --- fzf ---
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source $HOME/ghq/github.com/junegunn/fzf-git.sh/fzf-git.sh

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

## --- fzf theme ---
# Scheme name: Catppuccin Mocha
# Scheme system: base16
# Scheme author: https://github.com/catppuccin/catppuccin
# Template author: Tinted Theming (https://github.com/tinted-theming)

_gen_fzf_default_opts() {

local color00='#1e1e2e'
local color01='#181825'
local color02='#313244'
local color03='#45475a'
local color04='#585b70'
local color05='#cdd6f4'
local color06='#f5e0dc'
local color07='#b4befe'
local color08='#f38ba8'
local color09='#fab387'
local color0A='#f9e2af'
local color0B='#a6e3a1'
local color0C='#94e2d5'
local color0D='#89b4fa'
local color0E='#cba6f7'
local color0F='#f2cdcd'

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
}

_gen_fzf_default_opts

## --- fzf previews ---
show_file_or_dir_preview="if [ -d {} ]; then lsd --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'lsd --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


# --- other ---
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"
eval "$(fnm env --use-on-cd)"
eval "$(basher init - zsh)"
eval "$(kickstart infect)"
eval "$(rbenv init - zsh)"
eval "$(op signin)"

source "$HOME/.config/broot/launcher/bash/br"


