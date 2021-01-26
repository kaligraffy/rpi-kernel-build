#!/bin/bash
set -eu

declare -xr _BRANCH="";
declare -xr _SOURCE_URL="https://github.com/raspberrypi/linux";
declare -xr _PI_KERNEL_VERSION="kernel8l";
declare -xr _PI_VERSION="4"; #1,2,3,4, UNUSED
declare -xr _LOCAL_VERSION="${_PI_KERNEL_VERSION}-custom";
declare -xr _64BIT="y";
declare -xr _BUILD_ON_ARM="y";
declare -xr _MENUCONFIG="y"
