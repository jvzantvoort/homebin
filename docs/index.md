# homebin

Some useful script I use quite often.

# Installation

To install just clone the repo to "~/.tools":

    $ git clone https://github.com/jvzantvoort/homebin.git $HOME/.tools

Then add this (or something similar) to your bash profile:

   [[ "$-" =~ i ]]  && \
   [[ -d "$HOME/.tools/bin" ]] && \
   export PATH="$PATH:$HOME/.tools/bin"
