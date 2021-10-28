#!/bin/bash
#SBATCH --job-name=SpackInstaller
#SBATCH --partition=serc,normal
#SBATCH --cpus-per-task=12
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2g
#SBATCH --output=SpackInstaller_out_%j.out
#SBATCH --error=SpackInstaller_out_%j.out
#SBATCH --time=26:00:00
#
module purge
#
#
# CONSIDER (but after the set-env.sh)
# module load icc ifort
# spack find
# module unload icc ifort
#
echo "SLURM_CPUS_PER_TASK: ${SLURM_CPUS_PER_TASK}"
echo "SLURM_PARTITION: ${SLURM_PARTITION}"
#exit 42

module load gcc/10.

SPK_ENV="bogus"
if [[ ! -z $1 ]]; then
  SPK_ENV=$1
fi
#
PKG=""
if [[ ! -z $2 ]]; then
  PKG=$2
fi
#
#get arch (assume we're running on the intended architecture; for x86 builds, we'll have to specify. probably need to add
#  an arg-parser):
CODE_NAME=`/usr/local/sbin/cpu_codename -c` #the output of the cpu_codename command
#
# get arch
if [[ ${CODE_NAME} == "RME" ]]; then
    ARCH="zen2"
#
elif  [[ ${CODE_NAME} == "SKX" ]]; then
    ARCH="skylake"
else
    ARCH="x86_64"
fi
#
#
while getopts "e:p:a:" arg; do
  case $arg in
    e)
      echo "** Setting Environment: $OPTARG"
      SPK_ENV=$OPTARG
      ;;
    p)
      echo "** Setting Package: $OPTARG"
      PKG=$OPTARG
      ;;
    a)
      echo "Setting ARCH: $OPTARG"
      ARCH=$OPTARG
  esac
done
shift $((OPTIND -1))
#
if [[ -z $SPK_ENV ]]; then
  echo "*** ERROR: must specify an environment."
  exit 42
fi
#
# test:
echo "cp environment_configs/Core_zen2-beta/* spack/share/spack/lmod_${ARCH}_${SPK_ENV}/linux-centos7-x86_64/Core/"
#
#exit 7
# #####################
# do the installing...
#
. spack/share/spack/setup-env.sh
#
echo "*** Begin do_install for: :"
echo "*** SPK_ENV: ${SPK_ENV}, package=$2"
#
spack env activate $SPK_ENV
spack concretize --force
if [[ ! $? -eq 0 ]]; then
  spack concretize --force
fi
#
spack install -y --overwrite $2
#
spack module lmod refresh -y --delete-tree
# modules go to -> spack/share/spack/lmod_{arch}_{env}
cp -r environment_configs/Core_zen2-beta/* spack/share/spack/lmod_${ARCH}_${SPK_ENV}/linux-centos7-x86_64/Core/
#
