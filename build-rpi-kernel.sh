#!/bin/bash
# shellcheck disable=SC1091
set -eu

# Creates a rpi kernel
# Only rpi4 is supported atm
# Based on https://www.raspberrypi.org/documentation/linux/kernel/building.md

# Load functions, environment variables and dependencies
. functions.sh;
. env.sh;

#Program logic
main(){
  echo_info "$(basename $0) started";
  trap 'trap_on_exit' EXIT;
  check_run_as_root;
  install_dependencies;
    
  #Check for a build directory
  local delete_build=$(check_build_dir_exists);
  if (( $delete_build == 1 )); then
    rm -rf "$_BUILD_DIR";
  fi
  
  #Optimize for arm
  if [[ $_BUILD_ON_ARM == 'y' ]]; then
    MAKE_COMMAND="make -j4"
  fi
  
  #if a branch is set download that branch, otherwise get the head
  if [[ $( check_variable_is_set $_BRANCH ) ]]; then
    git clone --depth=1 --branch "$_BRANCH" "$_SOURCE_URL" "$_BUILD_DIR"
  else
    git clone --depth=1 "$_SOURCE_URL" "$_BUILD_DIR"
  fi
  
  declare -xr KERNEL=$_PI_KERNEL_VERSION 
  cd $_BUILD_DIR
  
  #decide if building for rpi4 64bit or not
  if [[ $_64BIT == 'y' ]]; then
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig
    if [[ $_MENUCONFIG == 'y' ]]; then
      make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
    fi
    $MAKE_COMMAND ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
  else  
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2711_defconfig
    if [[ $_MENUCONFIG == 'y' ]]; then
      make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
    fi
    $MAKE_COMMAND ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
  fi
  
  mv "$_BUILD_DIR/arch/arm/boot/zImage" "$_BUILD_DIR/arch/arm/boot/$_LOCAL_VERSION" | true
  mv "$_BUILD_DIR/arch/arm/boot/Image" "$_BUILD_DIR/arch/arm/boot/$_LOCAL_VERSION" | true

  echo_info "BUILD FINISHED, COPY TO /BOOT TO /BOOT!"
  exit 0;
}

# Run program
main;
