#!/bin/bash
#
# This script sets up the environment
#
#
#

#set -x #debug

#global variables

#directories
BASE_DIST_DIR="/oak/stanford/schools/ees/share/cees/software/spack_"


#sherlock modules
SHER_MOD_PATH="/share/software/modules/devel:/share/software/modules/math:/share/software/modules/categories"

#serc internal modules

SERC_MOD_PATH="/oak/stanford/schools/ees/share/cees/modules/modulefiles"

#dummy variable for spack module path

SPACK_MOD_PATH=""


#####

CODE_NAME=`/usr/local/sbin/cpu_codename -c` #the output of the cpu_codename command


#conditionals
if [[ ${CODE_NAME} == "RME" ]]; then

SPACK_MOD_PATH="${BASE_DIST_DIR}/zen2/spack/share/spack/lmod/linux-centos7-x86_64/Core"

elif  [[ ${CODE_NAME} == "SKX" ]]; then

SPACK_MOD_PATH="${BASE_DIST_DIR}/skylake/spack/share/spack/lmod/linux-centos7-x86_64/Core"

else
SPACK_MOD_PATH="${BASE_DIST_DIR}/x86_64/spack/share/spack/lmod/linux-centos7-x86_64/Core"

fi

# finally export the module environment 

export MODULEPATH="${SPACK_MOD_PATH}:${SERC_MOD_PATH}:${SHER_MOD_PATH}"



