#!/bin/bash
#
# This script sets up the environment
#
# yoder 22 sept 2021:
# making a few changes:
# 1) instead of explicitly setting the modulefiles, we will leave alone the standard sherlock environment(s) and let users
#    handle that on their own.
# 2) use modulle use {path} to set modules, instead of explicitly modifying the path.
#
#
#
#set -x #debug

#global variables

#directories
# TODO: rename this spack_beta or something...
BASE_DIST_DIR="/home/groups/s-ees/share/cees/spack_cees"
#
#sherlock modules
#SHER_MOD_PATH="/share/software/modules/devel:/share/software/modules/math:/share/software/modules/categories"

#serc internal modules
#SERC_MOD_PATH_OAK="/oak/stanford/schools/ees/share/cees/modules/modulefiles"
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
CODE_NAME=`/usr/local/sbin/cpu_codename -c` #the output of the cpu_codename command
#
#conditionals
if [[ ${CODE_NAME} == "RME" ]]; then
  SPACK_ARCH="zen2"
  SPACK_ENV_NAME="zen2-beta"
  #
elif  [[ ${CODE_NAME} == "SKX" ]]; then
  SPACK_ARCH="skylake"
  SPACK_ENV_NAME="skylake-beta"
  #
else
  # NOTE: this might actually be x86_64_v3, or in some cases haswell. It is not clear, just yet, how to best build the
  #   Arch-independent stack. GCC likes x86_64_v3, and appaers to possibly build more packages with it?; intel cannot
  #   build _v3 and bumps down to x86_64. When I set target=x86_64, a bunch of the Core bits get build as haswell
  #   (but they get build correctly in zen2 and skylake...). So it's a work in progress.
  #   For now, our intention is to build only one x86_64{?} environment. I think it is ok if it is mixed in its actual
  #   HW targeting (haswell, x86_64, x86_64_v3, or so) and we'll call it all x86_64.
  SPACK_ARCH="x86_64"
  SPACK_ENV_NAME="x86_64-beta"
fi
#SPACK_MOD_PATH="${BASE_DIST_DIR}/spack/share/spack/lmod_${SPACK_ENV_NAME}/linux-centos7-x86_64/Core"
SPACK_MOD_PATH="${BASE_DIST_DIR}/spack/share/spack/lmod_${SPACK_ARCH}_${SPACK_ENV_NAME}/linux-centos7-x86_64/Core"
CEES_MOD_DEPS_ARCH_PATH=${CEES_MOD_DEPS_PATH}_${SPACK_ARCH}
CEES_MOD_ARCH_PATH=${CEES_MOD_PATH}_${SPACK_ARCH}

# finally export the module environment
#
# module unuse any ${SPAC_ARCH} dependendent paths. Particularly for interactive sessions,
#  these can get set and propagated from a parent session (eg, SH03 compute architecture,
#  SH02 login).
# TODO: arch, environment names need to be cleaned up. I don't think it is easy to do a double-list in this version
#  of bash (easy in zshell...). For now, let's jst hack it...
for ARCH in zen2 skylake x86_64
do
  module unuse ${BASE_DIST_DIR}/spack/share/spack/lmod_${ARCH}_${ARCH}-beta/linux-centos7-x86_64/Core
  module unuse ${CEES_MOD_DEPS}_${ARCH}
  module unuse ${CEES_MOD_PATH}_${ARCH}
done

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
