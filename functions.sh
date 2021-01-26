#!/bin/bash
set -eu

#Global variables
declare -xr _BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
declare -xr _BUILD_DIR=${_BASE_DIR}/build
declare -xr _COLOR_ERROR='\033[0;31m' #red
declare -xr _COLOR_WARN='\033[1;33m' #orange
declare -xr _COLOR_INFO='\033[0;35m' #purple
declare -xr _COLOR_DEBUG='\033[0;37m' #grey
declare -xr _COLOR_NORMAL='\033[0m' # No Color
declare -xr _LOG_FILE="${_BASE_DIR}/build-$(date '+%Y-%m-%d-%H:%M:%S').log"
declare MAKE_COMMAND="make"
declare -xr KERNEL=$_PI_KERNEL_VERSION 

# Runs on script exit, tidies up the mounts.
trap_on_exit(){
  echo_info "$FUNCNAME";
  cleanup; 
  echo_info "$(basename $0) finished";
}

# Cleanup stage 2
cleanup(){
  echo_info "$FUNCNAME";     
}

install_dependencies() {
  echo_info "$FUNCNAME";
  apt-get -qq install git bc bison flex libssl-dev make libncurses5-dev 
  
  if [[ $_64BIT == 'y' ]]; then
    apt-get -qq install crossbuild-essential-arm64 
  else
    apt-get -qq install crossbuild-essential-armhf
  fi
}

#check if theres a build directory already
check_build_dir_exists(){
  #no echo as interferes with return echos
  if [ -d ${_BUILD_DIR} ]; then
        
    local continue;
    read -p "Build directory already exists: ${_BUILD_DIR}. Delete? (y/N)  " continue;
    if [ "${continue}" = 'y' ] || [ "${continue}" = 'Y' ]; then
      echo '1';
    else
      echo '0'; 
    fi
  else
    echo '1';
  fi
}

#checks if script was run with root
check_run_as_root(){
  echo_info "$FUNCNAME";
  if (( $EUID != 0 )); then
    echo_error "This script must be run as root/sudo";
    exit 1;
  fi
}

####PRINT FUNCTIONS####
echo_error(){ echo -e "${_COLOR_ERROR}$(date '+%H:%M:%S'): ERROR: $*${_COLOR_NORMAL}" | tee -a ${_LOG_FILE};}
echo_warn(){ echo -e "${_COLOR_WARN}$(date '+%H:%M:%S'): WARNING: $@${_COLOR_NORMAL}" | tee -a ${_LOG_FILE};}
echo_info(){ echo -e "${_COLOR_INFO}$(date '+%H:%M:%S'): INFO: $@${_COLOR_NORMAL}" | tee -a ${_LOG_FILE};}
echo_debug(){
  if [ $_LOG_LEVEL -lt 1 ]; then
    echo -e "${_COLOR_DEBUG}$(date '+%H:%M:%S'): DEBUG: $@${_COLOR_NORMAL}";
  fi
  #even if output is suppressed by log level output it to the log file
  echo "$(date '+%H:%M:%S'): $@" >> "${_LOG_FILE}";
}

