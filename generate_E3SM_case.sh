#!/bin/bash
# Author : Riley X. Brady
# Date : 11/04/2018
#
# This script sets up a g-case experiment with lagrangian particles, following
# all steps until submit.

# Directory of E3SM repository
E3SM_DIR=/turquoise/usr/projects/climate/rileybrady/E3SM_HPC_Class

# ------------------
# MODEL CONFIGURATION
# ------------------
res=T62_oEC60to30v3
nproc_ocean=512
nproc_ice=128
mach=wolf
pcode=w17_oceaneddies
input_dir=/lustre/scratch3/turquoise/maltrud/ACME/input_data

# ----------------------
# PARTICLE CONFIGURATION
# ----------------------
nvertlevels=0 # number of particles to seed in the vertical (0 = surface only)
output_frequency=2 # output frequency in days.

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

./create_newcase -s --case ../../${casename} --compset GMPAS-IAF --res ${res} \
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
cd ${HOMEDIR}

# Edit env_mach_specific to add mkl. 
echo "Editing env_mach_specific..."
python py/update_env_mach_specific.py --file ${E3SM_DIR}/${casename}/env_mach_specific.xml 

# Case setup
cd ${E3SM_DIR}/${casename}
echo "Setting up case directory..."
./case.setup -s

# Add particle files to case folder.
# Parameter expansion to find run directory
RUNDIR=$(./xmlquery --value CIME_OUTPUT_ROOT)
RUNDIR=${RUNDIR%/*}
RUNDIR=${RUNDIR}/cases/${casename}/run
mkdir particles
echo "Adding LIGHT utilities to case directory..."
cp ${E3SM_DIR}/components/mpas-source/testing_and_setup/compass/utility_scripts/LIGHTparticles/* particles

# Copy user_nl_mpaso into main directory
# NOTE : Need to add supercycling and RK functionality here.
cp particles/user_nl_mpaso .
cp particles/streams.ocean SourceMods/src.mpaso/streams.ocean.lagr
cp ${RUNDIR}/streams.ocean SourceMods/src.mpaso/streams.ocean.orig
cd SourceMods/src.mpaso
cp streams.ocean.orig streams.ocean
# Append Lagrangian streams to main streams.ocean file
cd ${HOMEDIR}
python py/append_streams_ocean.py --source ${E3SM_DIR}/${casename}/SourceMods/src.mpaso/streams.ocean.lagr \
    --dest ${E3SM_DIR}/${casename}/SourceMods/src.mpaso/streams.ocean \
    --particle ${RUNDIR}/particles.nc --outputfreq ${output_frequency} 

