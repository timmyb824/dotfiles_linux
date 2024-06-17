alias _=sudo
alias awsp="source _awsp"
alias awsprofile="source _awsp"
alias btm="btm --color gruvbox"
alias cat="bat"
alias cd..="cd .."
alias chez="chezmoi"
alias dockerps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Networks}}\t{{.State}}\t{{.RunningFor}}"'
alias dockerports='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.State}}\t{{.RunningFor}}"'
alias fdn='find . -type d -name' # fd is a seperate command
alias ff="find . -type f -name"
alias gop="gitopolis"
alias g=git
# alias k9s="k9s --kubeconfig ~/.kube/config_k3s "
alias kk=kubectl
alias kns='kubectl ns'
alias kcx='kubectl ctx'
alias lg="lazygit"
alias ldot="eza --icons=always -ld .*"
alias la="eza --icons=always -lAh --group"
alias ls="eza --icons=always"
alias ll="eza --icons=always -lh --group"
alias lst="eza --icons=always --tree"
alias oc="opencommit"
alias po=podman
alias poc='podman-compose'
alias podmanps='podman ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Networks}}\t{{.State}}\t{{.RunningFor}}"'
alias podmanports='podman ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.State}}\t{{.RunningFor}}"'
alias please=sudo
alias pr="poetry run"
alias px=pkgx
alias pxi="pkgx install"
alias quit=exit
alias reexec="exec zsh"
alias reload="source ~/.zshrc"
alias sopse="sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") -i "
alias sopsd="sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") -i "
alias sshadd="ssh-add ~/.ssh/id_master_key"
alias sshstart="eval `ssh-agent -s`"
alias tf=terraform
alias wtf=wtfutil
alias zbench="for i in {1..10}; do /usr/bin/time zsh -lic exit; done"
alias zshconfig="micro ~/.zshrc"
alias zj="zellij"
