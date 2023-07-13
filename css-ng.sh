#!/usr/bin/env bash

#   ____   ______ ______           ____    ____  
# _/ ___\ /  ___//  ___/  ______  /    \  / ___\ 
# \  \___ \___ \ \___ \  /_____/ |   |  \/ /_/  >
#  \___  >____  >____  >         |___|  /\___  / 
#      \/     \/     \/               \//_____/  
# 2023 • Deividas Gedgaudas • github.com/Sidicer

set -o nounset
set -o errtrace
set -o pipefail
IFS=$'\n\t'

# Verbosity (https://en.wikipedia.org/wiki/Syslog#Severity_level)
__VERBOSE=3
declare -A LOG_LEVELS
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .verbose () {
  local LEVEL=${1}
  shift
  if [ ${__VERBOSE} -ge ${LEVEL} ]; then
    echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
  fi
}

# Locate script
_ME="$(basename "${0}")"
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Defaults
_TEMPLATE=$_SCRIPT_DIR/template.nav
_INPUT=$_SCRIPT_DIR
_INPUTISFILE=false
_OUTPUT=$_SCRIPT_DIR

_print_help() {
  cat <<HEREDOC                                                       
   ____   ______ ______           ____    ____  
 _/ ___\ /  ___//  ___/  ______  /    \  / ___\ 
 \  \___ \___ \ \___ \  /_____/ |   |  \/ /_/  >
  \___  >____  >____  >         |___|  /\___  / 
      \/     \/     \/               \//_____/  
  2023 • Deividas Gedgaudas • github.com/Sidicer

This tool is used to generate "empty" navigation meshes
for all the maps inside provided directory

Usage:
  ./${_ME} [<arguments>]
  ./${_ME} -h | Show this screen
  ./${_ME} -v | Show [info] level output (Default [err] only)

  ./${_ME} -t | Use this if your .nav template is located elsewhere
                   or want to use another .nav template altogeher
  ./${_ME} -i | Provide a single .bsp file or a directory 
  ./${_ME} -o | Provide a directory for generated .nav files

Example:
  ./${_ME} -t /path/to/template.nav -i /path/to/[maps/map.bsp] -o /path/to/navs
  ./${_ME} - when used without any parameters tool looks for .bsp
                files in the same directory where ${_ME} is located
                and generates .nav files in the same directory
HEREDOC
}

_options() {
  _OPT_VERBOSE="${_OPT_VERBOSE:-false}"
  _OPT_HELP="${_OPT_HELP:-false}"
  _OPT_TEMPLATE="${_OPT_TEMPLATE:-false}"
  _OPT_INPUT="${_OPT_INPUT:-false}"
  _OPT_OUTPUT="${_OPT_OUTPUT:-false}"

  while getopts ":vht:i:o:" opt; do
    case $opt in
      v) _OPT_VERBOSE=true;;
      h) _OPT_HELP=true;;
      t) _OPT_TEMPLATE=true; _TEMPLATE=${OPTARG};;
      i) _OPT_INPUT=true; _INPUT=${OPTARG};;
      o) _OPT_OUTPUT=true; _OUTPUT=${OPTARG};;
      :) echo "[err] Option missing argument, see ./${_ME} -h"; exit 1;; 
      ?) echo "[err] Unknown option provided, see ./${_ME} -h"; exit 1;;
    esac
  done
  shift $((OPTIND-1))
}

_checkFiles() {
  .verbose 6 "Checking if $_TEMPLATE exists."
  if [ ! -f $_TEMPLATE ]; then
    .verbose 3 "$_TEMPLATE does not exist. Exiting..."
    exit 1
  fi
  .verbose 6 "$_TEMPLATE found"

  .verbose 6 "Checking if $_INPUT exists"
  if [ ! -e $_INPUT ]; then
    .verbose 3 "$_INPUT does not exist. Exiting..."
    exit 1
  fi
  .verbose 6 "$_INPUT found"

  .verbose 6 "Checking if $_INPUT is a file or directory"
  if [ -f $_INPUT ]; then
    _INPUTISFILE=true
    .verbose 6 "$_INPUT is a file"
  else
    .verbose 6 "Checking if there are any .bsp files in $_INPUT"
    _bsp_count=`ls -1 $_INPUT/*.bsp 2>/dev/null | wc -l`
    if [ $_bsp_count == 0 ]; then
      .verbose 3 "No .bsp files found in $_INPUT. Exiting..."
      exit 1
    fi
    .verbose 6 "$_bsp_count .bsp files found in $_INPUT"
  fi

  .verbose 6 "Checking if $_OUTPUT exists"
  if [ ! -d $_OUTPUT ]; then 
    .verbose 3 "$_OUTPUT does not exist. Creating..."
    mkdir -p $_OUTPUT
  fi
}

_generate() {
  if [ $_INPUTISFILE == true ]; then
    .verbose 6 "Generating $_OUTPUT/$(basename $_INPUT .bsp).nav from $_TEMPLATE"
    cp $_TEMPLATE $_OUTPUT/$(basename $_INPUT .bsp).nav
    if [ $? -ne 0 ]; then
      .verbose 3 "$_OUTPUT/$(basename $_INPUT .bsp).nav generation failed. Exiting..."
      exit 1
    fi
    .verbose 6 "$_OUTPUT/$(basename $_INPUT .bsp).nav generation successful"
  else
    _ALL_BSPS=$(ls -1 $_INPUT/*.bsp)
    for _FILE in $_ALL_BSPS; do
      .verbose 6 "Generating $_OUTPUT/$(basename $_FILE .bsp).nav from $_TEMPLATE"
      cp $_TEMPLATE $_OUTPUT/$(basename $_FILE .bsp).nav
      if [ $? -ne 0 ]; then
        .verbose 3 "$_OUTPUT/$(basename $_FILE .bsp).nav generation failed. Exiting..."
        exit 1
      fi
      .verbose 6 "$_OUTPUT/$(basename $_FILE .bsp).nav generation successful"
    done
  fi
}

_main() {
  _options "$@"
  if [[ $_OPT_VERBOSE == true ]]; then __VERBOSE=6; fi
  if [[ $_OPT_HELP == true ]]; then _print_help; exit 0; fi
  _checkFiles
  _generate
}

_main "$@"