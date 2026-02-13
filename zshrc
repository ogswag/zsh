os=$(uname)

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

if [ -f ~/.zsh/zsh_completion ]; then
    source ~/.zsh/zsh_completion
fi

if [ -f ~/.zsh/zsh_plugins ]; then
    source ~/.zsh/zsh_plugins
fi

if [ -f ~/.zsh/zsh_prompt ]; then
    source ~/.zsh/zsh_prompt
fi

export EDITOR='vim'
export SUDO_EDITOR='vim'
export VISUAL='vim'

mkcd () {
    mkdir -p "$1";
    cd "$1"
}

if [[ $os == "Linux" ]]; then
    export LD_LIBRARY_PATH=/usr/local/lib
elif [[ $os == "Darwin" ]]; then
    export PATH="$(brew --prefix)/bin:$PATH"
    export PATH="/usr/local/opt/jpeg/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
else
    echo "Unknown operating system."
fi

# ===== History Configuration =====
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt inc_append_history     # immediately append to history file, not just when a term is killed
setopt hist_find_no_dups      # don't show duplicates when searching history

# ===== Keybindings =====
bindkey '^\' redo

# ===== Other Options =====
setopt no_beep                  # disable beeping
setopt interactive_comments     # allow comments in interactive shells
setopt no_clobber               # prevent overwriting files with >
setopt no_flow_control          # disable start/stop output control
setopt auto_cd                  # cd by typing directory name without cd
setopt multios                  # enable multiple redirections
setopt prompt_subst             # enable parameter expansion in prompt

# ===== Directory Navigation =====
setopt auto_pushd               # make cd push old dir to dir stack
setopt pushd_ignore_dups        # don't push duplicates to dir stack
setopt pushdminus               # invert + and - meanings

# ===== Globbing and Expansion =====
setopt extended_glob            # enable extended globbing
setopt numeric_glob_sort        # sort numbered files numerically
unsetopt case_glob              # make globbing case-sensitive

# ===== Keybindings ===== {{{1
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^H' vi-backward-kill-word
