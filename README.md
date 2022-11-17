# The SERC Spack environment

**DEPRICATION NOTICE:**

Scripts, environments, etc. in this repository should generally be considered depricated. This content is derived largely from `serc_spack_env` and is being more or less succeeded by `cees_spack_configs`. This repo may still reflect the `-beta` environmens for CEES/SERC, but should generally be views for informational purposes, not as production repso.

**_NOTE:_** This has been significantly revised.
In its current conception, the install script will build Spack environments based on template `spack.yaml` files. The process is less than perfect and generally appears to encounter some problems solving the complex SW environment. Presently, the strategy is to maintain 3 environments (zen1, skylake, and x86, representative of HW in CEES' SERC partition) with `-03` optpimization for each. Each of those environments attempts a build for  (gcc, intel, oneapi) x (MPIs). The MPI is a mess because:
- `openmpi` does not compile for Intel (or OneAPI either -- ie, Intel's LLVM compilers?) without heroic efforts.
- `intel-oneapi-mpi` builds for GCC, but very very poorly. Deceptively poorly.
- `MPICH` seems to work all around, and is probably the better MPI. If you are going to support only one MPI, MPICH is probably a good choice.

TODO: Redefine the packages. In particular, get a better understanding of the generic definitions at the bottom of `packages.yaml`, for example `mpi: openmpi`, and especially the numerical libraries, `mkl: , blas:, ` etc.

----------

This is the Spack environment for SERC users on the Sherlock HPC System @ Stanford University.

By launching the install script it will; clone spack, copy over the configuration files, download and compile the needed compilers, and install software. 

It has an lmod Core based hierarchy that is helpful for many different packages.

## Files that may need to be modified

The install script should be modified for your platform of choice. Currently its hard coded for gcc 4.8.5 as its core compiler (CentOS 7).

The other file that definitely needs to be modified is the "modules.yaml" file within the defaults directory. The core compiler here is also gcc 4.8.5 which is based on CentOS 7. 

The packages.yaml can and should be modified to your given needs on the platform. 

## Known issues

The intel compilers can be finicky when downloading. Intel recently openned up the compiler downloads outside of Parallel Studio with their OneAPI initiative. Commenting out anything intel might be ideal in the install.sh script (although the intel compilers don't actually have to be built- which is nice). 

Current Spack bug where architecture is not fixed. Will submit a ticket soon. 
