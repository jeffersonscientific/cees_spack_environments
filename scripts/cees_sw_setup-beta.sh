#!/bin/bash
#
# This script sets up the environment
#
# Summary:
#  - Take as input or detect architecture
#  - Construct CEES module paths
#  - module unuse {every_version_of_ARCH_dependent_paths}
#  - module use {relevant paths}
#
# if we don't remove old paths, we can retain invalid architecture pahts from
unset SPACK_ARCH
unset SPACK_ENV_NAME
#
# Start with some inputs:
#echo "*** INPUTS: $1 ** $2 **"
if [[ ! -z $1 ]]; then
  SPACK_ARCH=$1
fi
#if [[ ! -z $2 ]]; then
#  SPACK_ENV_NAME=$2
#fi
#
FORCE_ARCH=0
DO_RESET=0
while getopts ":a:e:fr" opt; do
  case ${opt} in
    a )
      SPACK_ARCH=${OPTARG}
      #echo "setting SPACK_ARCH:  ${SPACK_ARCH}"
      ;;
    e )
      SPACK_ENV_NAME=${OPTARG}
      ;;
    f )
      FORCE_ARCH=1
      ;;
    r )
      DO_RESET=1
      ;;
    \? )
      # Do nothing...
      ;;
  esac
done
shift $((OPTIND-1))

#unset $1
#unset $2

#echo "** ** ARCH, ENV: ${SPACK_ARCH}, ${SPACK_ENV_NAME}"
#directories
BASE_DIST_DIR="/home/groups/s-ees/share/cees/spack_cees"
#
# standard sherlock modules
SHER_MOD_PATH="/share/software/modules/devel:/share/software/modules/math:/share/software/modules/categories"

#serc internal modules
#
# CEES developed modules (not Spack built):
# NOTE: The "generic" path is intended for packages that are *only* build without machine optimization, so there is only
#  one build. The ARCH paths are -- as they appear, designated for arch dependent builds. The generic (_x86) arch is separated
#  from the generc module path to avoid conflicts. Only packages with corresponding arch specific builds should go into _x86.
#  This framework will facilitate using older haswell (and possibly other) architectures from Owners.
CEES_MOD_PATH="/home/groups/s-ees/share/cees/modules/modulefiles"
#CEES_MOD_PATH_x86="/home/groups/s-ees/share/cees/modules/modulefiles_x86_64"
#CEES_MOD_PATH_zen2="/home/groups/s-ees/share/cees/modules/modulefiles_zen2"
#CEES_MOD_PATH_skylake="/home/groups/s-ees/share/cees/modules/modulefiles_skylake"
#
CEES_MOD_DEPS_PATH="/home/groups/s-ees/share/cees/modules/moduledeps"
#CEES_MOD_DEPS_PATH_x86="/home/groups/s-ees/share/cees/modules/moduledeps_x86_64"
#CEES_MOD_DEPS_PATH_zen2="/home/groups/s-ees/share/cees/modules/moduledeps_zen2"
#CEES_MOD_DEPS_PATH_skylake="/home/groups/s-ees/share/cees/modules/moduledeps_skylake"
#
#####
#
# Dict.. of ARCH:ENV values:
declare -A architectures
architectures["RME"]="zen2"
architectures["zen2"]="zen2"
architectures["skylake"]="skylake"
architectures["skylake-avx512"]="skylake"
architectures["SKX"]="skylake"
architectures["x86_64"]="x86_64"
architectures["x86_64_v2"]="x86_64"
architectures["x86_64_v3"]="x86_64"
architectures["x86_64_v4"]="x86_64"
architectures["haswell"]="x86_64"

declare -A DEFAULT_ARCH_ENV
DEFAULT_ARCH_ENV["zen2"]="zen2-beta"
DEFAULT_ARCH_ENV["skylake"]="skylake-beta"
DEFAULT_ARCH_ENV["x86_64"]="x86_64-beta"
#
#CODE_NAME=`/usr/local/sbin/cpu_codename -c` #the output of the cpu_codename command
#
if [[ -z ${SPACK_ARCH} ]]; then
  SPACK_ARCH=`/usr/local/sbin/cpu_codename -c`
fi

if [[ ${FORCE_ARCH} < 1 ]]; then
  if [[ ! -z ${architectures[${SPACK_ARCH}]} ]]; then
    SPACK_ARCH=${architectures[${SPACK_ARCH}]}
  else
    echo "*** Setting DEFAULT ARCH "
    SPACK_ARCH="x86_64"
  fi
fi
#
##
# has SPACK_ENV_NAME been set (by input prams)?
if [[ -z ${SPACK_ENV_NAME} ]]; then
  if [[ -z ${DEFAULT_ARCH_ENV[${SPACK_ARCH}]} ]]; then
    SPACK_ARCH="x86_64"
  fi
  SPACK_ENV_NAME=${DEFAULT_ARCH_ENV[${SPACK_ARCH}]}
fi
# Now, we should have SPACK_ARCH and SPACK_ENV_NAME. They might not be valid, if passed as prams, but
#   should be valid if *not* passed. If one invalid input, we should fail to x86_64.
#
#SPACK_MOD_PATH="${BASE_DIST_DIR}/spack/share/spack/lmod_${SPACK_ENV_NAME}/linux-centos7-x86_64/Core"
SPACK_MOD_PATH="${BASE_DIST_DIR}/spack/share/spack/lmod_${SPACK_ARCH}_${SPACK_ENV_NAME}/linux-centos7-x86_64/Core"
CEES_MOD_DEPS_ARCH_PATH=${CEES_MOD_DEPS_PATH}_${SPACK_ARCH}
CEES_MOD_ARCH_PATH=${CEES_MOD_PATH}_${SPACK_ARCH}

# finally export the module environment
echo "ARCH: ${SPACK_ARCH}"
echo "ENV:  ${SPACK_ENV_NAME}"
#
if [[ ${DO_RESET} > 0 ]]; then
  export MODULEPATH=${SHER_MOD_PATH}
fi
# module unuse any ${SPAC_ARCH} dependendent paths. Particularly for interactive sessions,
#  these can get set and propagated from a parent session (eg, SH03 compute architecture,
#  SH02 login).
#
#for ARCH in zen2 skylake x86_64
for ARCH in ${!DEFAULT_ARCH_ENV[@]}
do
  #env=${ARCH}-beta
  env=${DEFAULT_ARCH_ENV[${ARCH}]}
  echo "** CEES Setup: Unsetting ARCH=${ARCH}, ENV=${env}"
  #
  module unuse ${BASE_DIST_DIR}/spack/share/spack/lmod_${ARCH}_${SPACK_ENV_NAME}/linux-centos7-x86_64/Core
  module unuse ${CEES_MOD_DEPS}_${ARCH}
  module unuse ${CEES_MOD_PATH}_${ARCH}
done
#
echo "** CEES Setup: Setting ARCH=${SPACK_ARCH}, ENV=${SPACK_ENV_NAME}"

#export MODULEPATH="${SPACK_MOD_PATH}:${SERC_MOD_PATH}:${SHER_MOD_PATH}"
#
#echo "** Enabling SpackCore: ${SPACK_MOD_PATH}"
#
# ARCH independent:
module use ${CEES_MOD_PATH}
module use ${CEES_MOD_DEPS_PATH}
#
# ARCH dependent:
module use ${SPACK_MOD_PATH}
module use ${CEES_MOD_ARCH_PATH}
module use ${CEES_MOD_DEPS_ARCH_PATH}
#
