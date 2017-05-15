#    _               _                           __ _ _
#   | |__   __ _ ___| |__       _ __  _ __ ___  / _(_) | ___
#   | '_ \ / _` / __| '_ \     | '_ \| '__/ _ \| |_| | |/ _ \
#  _| |_) | (_| \__ \ | | |    | |_) | | | (_) |  _| | |  __/
# (_)_.__/ \__,_|___/_| |_|____| .__/|_|  \___/|_| |_|_|\___|
#                        |_____|_|
#

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if [ -f ~/.bash_profile.local ]; then
  source ~/.bash_profile.local
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
export PATH

# rbenv
if [ -d ~/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init -)"
fi

