#!/bin/bash
#===============================================================================
#
#         FILE:  bootstrap_centos7_ws.sh
#
#        USAGE:  bootstrap_centos7_ws.sh
#
#  DESCRIPTION:  bootstrap a CentOS 7 workstation
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  jvzantvoort (John van Zantvoort), john@vanzantvoort.org
#      COMPANY:  JDC
#      CREATED:  2020-10-24
#
# Copyright (C) 2020 John van Zantvoort
#
#===============================================================================
readonly CONST_SCRIPTPATH="$(readlink -f $0)"
readonly CONST_SCRIPTNAME="$(basename $CONST_SCRIPTPATH .sh)"
readonly CONST_SCRIPTDIR="$(dirname $CONST_SCRIPTPATH)"
readonly CONST_FACILITY="local0"

#------------------------------------------------------------------------------#
#                                    Main                                      #
#------------------------------------------------------------------------------#

echo "Install packages"
sudo yum -y install wget git tmux

echo "Setup bashrc"
git clone https://github.com/jvzantvoort/jvzantvoort-bash-config.git .bash
./.bash/build/bootstrap.sh -y

echo "Setup tools"
git clone https://github.com/jvzantvoort/homebin.git $HOME/.tools

echo "Setup vim"
git clone https://github.com/jvzantvoort/jvzantvoort-vim-config.git .vim
bash .vim/bootstrap.sh

pushd ~/.tools/bin
wget https://github.com/jvzantvoort/center_text/releases/download/center_text-0.0.2/center_text_center_text-0.0.2_linux_amd64.zip
unzip center_text_center_text-0.0.2_linux_amd64.zip
rm center_text_center_text-0.0.2_linux_amd64.zip
popd

#------------------------------------------------------------------------------#
#                                  The End                                     #
#------------------------------------------------------------------------------#
