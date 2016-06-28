#!/usr/bin/env bash

shopt -s -o pipefail
set -e

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Misc bash startup files"
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function build() {
    cat > /etc/profile << "EOF"
# Begin /etc/profile

for script in /etc/profile.d/*.sh
do
  source $script
done
unset script

# End /etc/profile
EOF

	install -d -m755 /etc/profile.d

	cat > /etc/profile.d/05-i18n.sh << "EOF"
# Begin /etc/profile.d/05-i18n.sh

export LANG=en_US.UTF-8
export G_FILENAME_ENCODING=@locale

# End /etc/profile.d/05-i18n.sh
EOF

	cat > /etc/profile.d/10-path.sh << "EOF"
# Begin /etc/profile.d/10-path.sh

if [ "$EUID" -eq 0 ]; then
  export PATH="/sbin:/bin:/usr/sbin:/usr/bin"
  if [ -d "/usr/local/sbin" ]; then
    export PATH="$PATH:/usr/local/sbin"
  fi
else
  export PATH="/bin:/usr/bin"
fi

if [ -d "/usr/local/bin" ]; then
  export PATH="$PATH:/usr/local/bin"
fi

if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# End /etc/profile.d/10-path.sh
EOF

	cat > /etc/profile.d/10-xdg.sh << "EOF"
# Begin /etc/profild.d/10-xdg.sh

export XDG_DATA_DIRS="/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg:/usr/share"

# End /etc/profild.d/10-xdg.sh
EOF

	cat > /etc/profile.d/50-dircolors.sh << "EOF"
# Begin /etc/profile.d/50-dircolors.sh

alias ls='ls --color=auto'
if [ -f "$HOME/.dircolors" ]; then
  eval `dircolors -b "$HOME/.dircolors"`
else
  if [ -f "/etc/dircolors" ]; then
    eval `dircolors -b "/etc/dircolors"`
  fi
fi

# End /etc/profile.d/50-dircolors.sh
EOF

	dircolors -p > /etc/dircolors

	cat > /etc/profile.d/50-history.sh << "EOF"
# Begin /etc/profile.d/50-history.sh

export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# End /etc/profile.d/50-history.sh
EOF

	cat > /etc/profile.d/50-prompt.sh << "EOF"
# Begin /etc/profile.d/50-prompt.sh

export PS1="\u:\w\$ "
if [ "${TERM:0:5}" = "xterm" ]; then
  export PS1="\[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;31m\]\H \[\e[1;34m\]\w \[\e[1;32m\]\$ \[\e[0;0m\]"
fi

shopt -s checkwinsize

# End /etc/profile.d/50-prompt.sh
EOF

	cat > /etc/profile.d/50-readline.sh << "EOF"
# Begin /etc/profile.d/50-readline.sh

if [ -z "$INPUTRC" ]; then
  if [ -f "$HOME/.inputrc" ]; then
    export INPUTRC="$HOME/.inputrc"
  else
    if [ -f "/etc/inputrc" ]; then
      export INPUTRC="/etc/inputrc"
    fi
  fi
fi

# End /etc/profile.d/50-readline.sh
EOF

	cat > /etc/profile.d/50-umask.sh << "EOF"
# Begin /etc/profile.d/50-umask.sh

if [ "`id -un`" = "`id -gn`" -a $EUID -gt 99 ]; then
  umask 002
else
  umask 022
fi

# End /etc/profile.d/50-umask.sh
EOF
}

# Run the installation procedure
time { showHelp;build; }
# Verify installation
if [ -d /etc/profile.d ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi