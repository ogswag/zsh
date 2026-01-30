os=$(uname)

# Clone Moarram/headline if not already present
if [[ ! -d ~/.config/zsh/headline ]]; then
    echo "Cloning Moarram/headline into ~/.config/zsh/headline..."
    mkdir -p ~/.config/zsh
    git clone https://github.com/Moarram/headline.git ~/.config/zsh/headline
    if [[ $? -eq 0 ]]; then
        echo "Successfully cloned headline."
    else
        echo "Failed to clone headline. Please check your internet or Git configuration."
    fi
fi
source ~/.config/zsh/headline/headline.zsh-theme

HL_SEP_MODE='on'

HL_LAYOUT_TEMPLATE=(
  _PRE    "${IS_SSH+ %{$reset$yellow$bold%\}[ssh] }"
  USER    '...'
  HOST    '...'
  VENV    ' ...'
  PATH    ' in ...'
  _SPACER '' # special, only shows when compact, otherwise fill with space
  BRANCH  ' ...'
  STATUS  ' (...)'
  _POST   ''
)
HL_CONTENT_TEMPLATE=(
  USER   "%{$bold$blue%}..."
  HOST   "%{$bold$blue%}@..."
  VENV   "%{$bold$green%}(...)"
  PATH   "%{$bold$red%}..."
  BRANCH "%{$bold$green%}..."
  STATUS "%{$bold$yellow%}..."
)
HL_PROMPT='❯ ' # consider '%#'
HL_GIT_COUNT_MODE='on'
HL_GIT_SEP_SYMBOL='|'
HL_GIT_STATUS_SYMBOLS[STAGED]="%{$green%}+"
HL_GIT_STATUS_SYMBOLS[CHANGED]="%{$yellow%}!"
HL_GIT_STATUS_SYMBOLS[CONFLICTS]="%{$red%}X"
HL_GIT_STATUS_SYMBOLS[CLEAN]="%{$green%}✓"
HL_ERR_MODE='detail'

source ~/.zsh_aliases

export EDITOR='vim'
export VISUAL='vim'

mkcd () {
    mkdir -p "$1";
    cd "$1"
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias cd-focus-config="cd ~/Library/Application\ Support/dev.focus-editor"

    export PATH="/usr/local/opt/jpeg/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    export PATH="/usr/local/bin:$PATH"
    export PATH="$(brew --prefix)/bin:$PATH"
fi

##? Clone a plugin, identify its init file, source it, and add it to your fpath.
function plugin-load {
  local repo plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/.zsh_plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules \
        https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# where do you want to store your plugins?
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins}

# get zsh_unplugged and store it with your other plugins
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

# make list of the Zsh plugins you use
repos=(
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-history-substring-search
)

# now load your plugins
plugin-load $repos

# zsh-history-substring-search configuration
bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# ===== Completion System =====
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i  # only load completions if dump file is older than 24 hours
else
  compinit -C -i  # skip security check for faster load
fi
setopt menu_complete  # autoselect the first completion entry
setopt auto_menu        # show completion menu on successive tab press
setopt complete_in_word # allow completion from within a word
setopt always_to_end    # move cursor to end if word had one match
setopt completealiases

# Case-insensitive, partial-word, and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z-_}={A-Za-z_-}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
# Show descriptions when completion options exist
zstyle ':completion:*' verbose yes

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

# Group matches and describe what type they are
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{blue}-- %d --%f'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-dirs-first true

# Better completion for kill, ps, and other system commands
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Allow approximate completions (after pressing Ctrl+X a)
zstyle ':completion:*' completer _complete _match _history _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# SSH/SCP/RSYNC host completion from known_hosts
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

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
bindkey -e  # emacs keybindings
bindkey '^U' backward-kill-line  # Ctrl+U - kill to beginning of line (like bash)
bindkey '^[[3;5~' kill-word      # Ctrl+Del - kill word forward
bindkey '^H' backward-kill-word  # Ctrl+Backspace - kill word backward

# ===== Enhanced Emacs Keybindings =====
bindkey -e  # Ensure emacs keybindings are enabled

# Define a function to paste clipboard content
function paste-from-clipboard {
  # macOS
  if command -v pbpaste &>/dev/null; then
    LBUFFER+=$(pbpaste 2>/dev/null)
  # Linux (X11/Wayland)
  elif command -v wl-paste &>/dev/null; then
    LBUFFER+=$(wl-paste 2>/dev/null)
  elif command -v xsel &>/dev/null; then
    LBUFFER+=$(xsel -b 2>/dev/null)
  elif command -v xclip &>/dev/null; then
    LBUFFER+=$(xclip -selection clipboard -o 2>/dev/null)
  else
    echo "Error: No clipboard tool found!" >&2
  fi
}

# Register the function as a Zsh widget
zle -N paste-from-clipboard

# Bind Ctrl+Y to the widget
bindkey '^Y' paste-from-clipboard

# Ctrl+S - Enter selection mode (emacs style)
bindkey '^s' set-mark-command  # Set mark at current position

# Ctrl+W - Copy selected text to clipboard without killing (for emacs style copy)
bindkey '^w' copy-region-as-kill-to-clipboard
function copy-region-as-kill-to-clipboard() {
  zle copy-region-as-kill
  if [[ "$OSTYPE" = darwin* ]]; then
    echo -n "$CUTBUFFER" | pbcopy
  else
    echo -n "$CUTBUFFER" | xclip -i -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null
  fi
}
zle -N copy-region-as-kill-to-clipboard

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

if [[ $os == "Linux" ]]; then
    export LD_LIBRARY_PATH=/usr/local/lib
elif [[ $os == "Darwin" ]]; then
    export PATH="/usr/local/opt/jpeg/bin:$PATH"
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "Unknown operating system."
fi

