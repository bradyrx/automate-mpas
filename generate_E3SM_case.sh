#!/bin/bash
# Author : Riley X. Brady
# Date : 11/04/2018
#
# This script sets up a g-case experiment with lagrangian particles, following
# all steps until submit.
E3SM_DIR=/turquoise/usr/projects/climate/rileybrady/E3SM_HPC_Class

# setup
res=T62_oEC60to30v3
nproc_ocean=512
nproc_ice=128
mach=wolf
pcode=w17_oceaneddies
input_dir=/lustre/scratch3/turquoise/maltrud/ACME/input_data

# particles
nvertlevels=0

# Case setup.
echo "Setting up case..."
echo "------------------"

HOMEDIR=`pwd`

cd ${E3SM_DIR}/cime/scripts
casename=GMPAS-IAF.${res}.${mach}.${nproc_ocean}o.${nproc_ice}i
if (( nvertlevels == 0 )) 
then
    casename=${casename}.noParticles
    PARTICLES=false
else
    casename=${casename}.${nvertlevels}ParticleLayers
    PARTICLES=true
fi 

# check if case exists to avoid overwrite.
if [ -d "../../$casename" ]
then
    echo "ERROR: Specified case already exists."
    exit 1
fi

./create_newcase --case ../../${casename} --compset GMPAS-IAF --res ${res} \
    --mach ${mach} --compiler gnu --mpilib openmpi --project ${pcode} \
    --input-dir ${input_dir}
cd ${HOMEDIR} 

# Set nprocs
cd ${E3SM_DIR}/${casename}
echo "Setting nprocs to ${nproc_ocean} for the ocean."
./xmlchange -s --file env_mach_pes.xml NTASKS_OCN=${nproc_ocean} 
echo "Setting nprocs to ${nproc_ice} for the ice."
./xmlchange -s --file env_mach_pes.xml NTASKS_ICE=${nproc_ice}
./xmlchange -s --file env_mach_pes.xml ROOTPE_OCN=${nproc_ice}

# Edit env_mach_specific to add mkl. 

# Run case.setup.
