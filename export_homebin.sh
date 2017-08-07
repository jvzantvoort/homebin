#!/bin/bash
#===============================================================================
#
#         FILE:  export_homebin.sh
#
#        USAGE:  export_homebin.sh
#
#  DESCRIPTION:  Bash script
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  John van Zantvoort (jvzantvoort), John@vanZantvoort.org
#      COMPANY:  none
#      CREATED:  07-Aug-2017
#===============================================================================

declare -r CONST_SCRIPTPATH="$(readlink -f $0)"
declare -r CONST_SCRIPTNAME="$(basename $CONST_SCRIPTPATH .sh)"
declare -r CONST_SCRIPTDIR="$(dirname $CONST_SCRIPTPATH)"
declare -r CONST_FACILITY="local0"
declare -r CONST_PROJECTNAME="homebin"
declare -r CONST_PROJECTURL="https://github.com/jvzantvoort/homebin.git"
declare -xr LANG="C"

# If not in jenkins
[[ -z "$WORKSPACE" ]] && WORKSPACE="$HOME/tmp"

function logging()
{
  local priority="$1"; shift
  logger -p ${CONST_FACILITY}.${priority} -i -s -t "${CONST_SCRIPTNAME}" -- "${priority} $@"
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
  local STRING="$1"
  local RETV="${2:-0}"
  if [ "$RETV" = "0" ]
  then
    logging_info "$STRING"
  else
    logging_err "$STRING"
  fi
  exit $RETV
}

function pathmunge()
{
  [ -d "$1" ] || return

  EGREP="$(which --skip-alias egrep)"
  [[ -z "${EGREP}" ]] && script_exit "ERROR: egrep not found" 1

  if echo $PATH | $EGREP -q "(^|:)$1($|:)"
  then
    return
  fi

  if [ "$2" = "after" ]
  then
      PATH=$PATH:$1
  else
      PATH=$1:$PATH
  fi
}

#===  FUNCTION  ================================================================
#         NAME:  mkstaging_area
#  DESCRIPTION:  Creates a temporary staging area and set the variable
#                $STAGING_AREA to point to it
#   PARAMETERS:  STRING, mktemp template (optional)
#      RETURNS:  0, oke
#                1, not oke
#===============================================================================
mkstaging_area()
{
  local TEMPLATE RETV
  TEMPLATE="${WORKSPACE}/${CONST_PROJECTNAME}.XXXXXXXX"

  [[ -z "$1" ]] || TEMPLATE="$1"

  STAGING_AREA=$(mktemp -d ${TEMPLATE})
  RETV=$?

  if [ $RETV == 0 ]
  then
    return 0
  else
    logging_info "mkstaging_area failed $RETV"
    return 1
  fi

  return 0
} # end: mkstaging_area

#===  FUNCTION  ================================================================
#         NAME:  git_exp
#  DESCRIPTION:  export a git repo to a select destination
#   PARAMETERS:  STRING, source url
#                STRING, dest dir
#      RETURNS:  nothing
#===============================================================================
git_exp()
{
    local SOURCEURL=$1
    logging_info "sourceurl: $SOURCEURL"
    local DESTDIR=$2
    logging_info "destdir: $DESTDIR"
    local TAG=$3

    [[ -z "$TAG" ]] && TAG=$(git describe --abbrev=0 --tags)
    logging_info "tag: $TAG"

    local LONG_HASH=$TAG
    local SHORT_HASH=$TAG

    if [ "$TAG" = "HEAD" ]
    then
      LONG_HASH=`git rev-parse HEAD`
      SHORT_HASH="${CONST_PROJECTNAME}-`git log --pretty=format:'%h' -n 1`"
    fi
    local OUTPUTFILE="${SHORT_HASH}.tar"
    logging_info "long hash: $LONG_HASH"
    logging_info "short hash: $SHORT_HASH"

    BASENAME=$(basename $SOURCEURL .git)
    logging_info "basename: $BASENAME"

    [[ -d "$DESTDIR" ]] || mkdir -p "$DESTDIR"

    mkdir -p $STAGING_AREA/src/$BASENAME
    cd $STAGING_AREA/src
    git clone $SOURCEURL $BASENAME
    pushd $BASENAME
    git archive \
      --format=tar \
      --prefix="${SHORT_HASH}/" \
      --output=$DESTDIR/${OUTPUTFILE} \
      $LONG_HASH
    popd
    logging_info "compression, start"
    [[ -f "$DESTDIR/${OUTPUTFILE}.gz" ]] && rm -f "$DESTDIR/${OUTPUTFILE}.gz"
    gzip -9 "$DESTDIR/${OUTPUTFILE}"
    logging_info "compression, end"

} # end: git_exp
#------------------------------------------------------------------------------#
#                                    Main                                      #
#------------------------------------------------------------------------------#

logging_info "start"

# setup path
#---------------------------------------
pathmunge "${HOME}/bin" "after"
export PATH
TAG=$1

TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUTDIR="vimconfig_${TIMESTAMP}"
logging_info "create staging area"

[[ -d "${WORKSPACE}" ]] || mkdir -p "${WORKSPACE}"

mkstaging_area || die "mkstaging_area failed"
[[ -z "$STAGING_AREA" ]] && die "STAGING_AREA variable is empty"

mkdir -p $STAGING_AREA/src || die "cannot create src dir"

git_exp $CONST_PROJECTURL "$HOME/exports" $TAG

[[ -d "${STAGING_AREA}" ]] && rm -rf "${STAGING_AREA}"

script_exit "end"
#------------------------------------------------------------------------------#
#                                  The End                                     #
#------------------------------------------------------------------------------#
