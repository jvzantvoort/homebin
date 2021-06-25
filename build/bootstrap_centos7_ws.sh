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
readonly C_SCRIPTPATH="$(readlink -f $0)"
readonly C_SCRIPTNAME="$(basename $C_SCRIPTPATH .sh)"
readonly C_SCRIPTDIR="$(dirname $C_SCRIPTPATH)"
readonly C_FACILITY="local0"
readonly C_FOLDERS=$(cat <<-FOLDERS
~/.cache 775
~/.config 775
~/.gnupg 700
~/.local 700
~/.ssh 700
~/bin 755
~/Archive 755
~/Desktop 755
~/Documents 755
~/Downloads 755
~/rpmbuild 755
~/rpmbuild/BUILD 755
~/rpmbuild/BUILDROOT 755
~/rpmbuild/RPMS 755
~/rpmbuild/SOURCES 755
~/rpmbuild/SPECS 755
~/rpmbuild/SRPMS 755
~/tmp 775
~/Workspace 755
~/go 755
~/go/src 755
~/go/bin 755
~/go/pkg 755
FOLDERS
)
readonly C_CENTER_TEXT="https://github.com/jvzantvoort/center_text/releases/download/center_text-0.0.2/center_text_center_text-0.0.2_linux_amd64.zip"

# logging {{{
function title()
{
  local mesg="$1"
  tput bold
  printf "\n>> %s\n\n" "${mesg}"
  tput sgr0
}

function logging()
{
  local priority="$1"; shift
  logger -p ${C_FACILITY}.${priority} -i -s -t "${C_SCRIPTNAME}" -- "${priority} $@"
}

function logging_err()
{
  logging "err" "$@"
}

function logging_info()
{
  logging "info" "$@"
}

function script_exit()
{
  local message="$1"
  local retv="${2:-0}"
  if [ "$retv" = "0" ]
  then
    logging_info "$message"
  else
    logging_err "$message"
  fi
  exit "${retv}"
}
# }}}

# prompt {{{
function askyn()
{
  local mesg="$1"
  local default="$2"
  local retv
  local color_start=$(tput -Tansi setaf 6)
  local color_bold=$(tput bold)
  local color_end=$(tput -Tansi sgr0)
  local yn

  if [[ "${default}" == "n" ]]
  then
    yn="y|${color_bold}n${color_end}"
  else
    yn="${color_bold}y${color_end}|n"
  fi

  while :
  do
    printf "%s%s?%s [%s] > " "${color_start}" "${mesg}" "${color_end}" "${yn}"
    read ANSWER
    [[ -z "${ANSWER}" ]] && ANSWER="${default}"
    case "${ANSWER}" in
      y*|Y*) retv=0; break ;;
      n*|N*) retv=1; break ;;
      *) continue
    esac
  done
  return "${retv}"
}
# }}}

# create folders {{{
function __mkdirp()
{
  local folderpath="$1"
  local mode="$2"
  local message="create folderpath ${folderpath}"
  local retv=0

  logging_info "${message}, start"

  if [[ ! -d "$folderpath" ]]
  then
    logging_info "${message}, creating dir"
    mkdir -m "${mode}" "${folderpath}"
  fi

  # Sometimes they are links
  if [[ -h "${folderpath}" ]]
  then
    logging_info "${message}, end"
    return 0
  fi

  rmode=$(stat -c %a "${folderpath}")

  if [[ "${rmode}" != "${mode}" ]]
  then
    chmod "${mode}" "${folderpath}"
  fi

  logging_info "${message}, end"
  return "${retv}"
}

function create_folders()
{
  while read -u 4 -r folderpath mode
  do
    folderpath=${folderpath/\~/$HOME}
    __mkdirp "${folderpath}" "${mode}"
  done 4< <(echo "${C_FOLDERS}" )
}
# }}}

# gitclone {{{
function gitclone()
{

  local url="$1"
  local dir="$2"
  local string

  string="checkout ${url}"
  echo "START ${string}"

  if [[ -e "${dir}/.git/config" ]]
  then
    echo "    already checked out"
    echo "END   ${string}"
    return 0
  fi

  git clone "${url}" "${dir}"

  echo "END   ${string}"
}
# }}}

# install_center_text {{{
function install_center_text()
{
  title "Install center_text"

  pushd "${HOME}" >/dev/null 2>&1 || return 1

  logging_info "Get center_text"
  wget -q "${C_CENTER_TEXT}" || return 2


  bn=$(basename ${C_CENTER_TEXT})

  logging_info "Unpack ${bn}"
  unzip -o "${bn}" || return 3
  rm "${bn}"

  if [[ -e "${HOME}/.tools/bin/center_text" ]]
  then
    logging_info "center_text exists"
    if cmp "${HOME}/.tools/bin/center_text" center_text
    then
      rm -f center_text
      return 0
    fi
  fi
  mv center_text "${HOME}/.tools/bin/center_text"
  chmod 755 "${HOME}/.tools/bin/center_text"
  popd >/dev/null 2>&1 || return 1
}
# }}}

# install_vimrc {{{
function install_vimrc()
{
  local retv

  retv=0

  title "Setup vimrc"

  if [[ ! -e "${HOME}/.vimrc" ]]
  then
    ln -s "${src}" "${dst}"
  fi

  src=$(readlink -f "${HOME}/.vim/main.vim")
  dst=$(readlink -f "${HOME}/.vimrc")

  if [[ "${src}" != "${dst}" ]]
  then
    NOW=$(date +%y%m%d.%H%M%S)
    mv -v "$HOME/.vimrc" "$HOME/.vimrc.bck${NOW}"
    ln -s "${src}" "${dst}"
  fi

  __mkdirp "$HOME/.vim/autoload" 755 || retv=1
  __mkdirp "$HOME/.vim/bundle"   755 || retv=2

  gitclone "https://github.com/VundleVim/Vundle.vim.git" \
     "${HOME}/.vim/bundle/Vundle.vim"

  vim +PluginInstall +qall

  return "${retv}"

}
# }}}

# install_bashrc {{{
function install_bashrc()
{
  title "Setup bashrc"
  if ! grep -q '/.bash/bashrc.sh' ~/.bashrc
  then
    cat >> "${HOME}/.bashrc" << 'END_OF_BASHRC'

# User specific aliases and functions
[[ -f "${HOME}/.bash/bashrc.sh" ]] && . "${HOME}/.bash/bashrc.sh"
END_OF_BASHRC
  fi

}
# }}}

#------------------------------------------------------------------------------#
#                                    Main                                      #
#------------------------------------------------------------------------------#
title "Package"

if askyn "Install needed packages" "n"
then
  echo "Install packages"
  sudo yum -y install wget git tmux
fi

title "Create folders"
create_folders

title "Git options"
askyn "Use ssh git for checkout" "n"
SSH_GIT="$?"

if [[ "${SSH_GIT}" == "0" ]]
then
  BASH_GIT_URL="git@github.com:jvzantvoort/jvzantvoort-bash-config.git"
  HOMEBIN_GIT_URL="git@github.com:jvzantvoort/homebin.git"
  VIMRC_GIT_URL="git@github.com:jvzantvoort/jvzantvoort-vim-config.git"

else
  BASH_GIT_URL="https://github.com/jvzantvoort/jvzantvoort-bash-config.git"
  HOMEBIN_GIT_URL="https://github.com/jvzantvoort/homebin.git"
  VIMRC_GIT_URL="https://github.com/jvzantvoort/jvzantvoort-vim-config.git"
fi

title "Checkout configs"
gitclone "${BASH_GIT_URL}" "${HOME}/.bash"
gitclone "${HOMEBIN_GIT_URL}" "$HOME/.tools"
gitclone "${VIMRC_GIT_URL}" "${HOME}/.vim"

install_center_text

install_bashrc

install_vimrc

#------------------------------------------------------------------------------#
#                                  The End                                     #
#------------------------------------------------------------------------------#
# vim: foldmethod=marker
