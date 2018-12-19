#!/bin/bash
# Author : Riley X. Brady
# Date : 11/04/2018
#
# This script sets up a g-case experiment with lagrangian particles, following
# all steps until submit.
# ------------------
E3SM_DIR=/path/to/E3SM/directory

# ------------------
# MODEL CONFIGURATION
# ------------------
BGC=false # whether or not to have a BGC active run
res=T62_oEC60to30v3
nproc_ocean=512
nproc_ice=128
mach=grizzly
pcode=ACCOUNT # place account here
input_dir=/lustre/scratch3/turquoise/maltrud/ACME/input_data

# ------------------
# RUN CONFIGURATION
# ------------------
WALLCLOCK=00:20:00
STOP_OPTION=ndays # select either "ndays" or "nmonths"
STOP_N=5 # number of days/months depending on STOP_OPTION

# ----------------------
# PARTICLE CONFIGURATION
# ----------------------
nvertlevels=10 # number of particles to seed in the vertical (0 = no particles). NOTE: May need to edit this a bit if user wants only surface particles.
output_frequency=2 # output frequency in days.
# vertseedtype=linear # seed strategy for particles; currently not supported
particletype=(surface passive) # space-separated particle types

# -----------------------------
# PARTICLE SENSOR CONFIGURATION
# -----------------------------
# This determines whether or not sampling will be turned on for the given
# variables.
sampleTemperature=false
sampleSalinity=false
sampleDIC=false
sampleALK=false
samplePO4=false
sampleNO3=false
sampleSiO3=false
sampleNH4=false
sampleFe=false
sampleO2=false

# ----------------------
# START CODE
# ----------------------
echo "NOTE: Make sure to enable a python2.7 environment."

# Checking some early stuff to not waste user's time
# (1) See if a few critical packages are installed for python.
python -c "import lxml"
if (( $? == 1 )); then
    echo "You must install lxml for python before continuing."
    exit 1  
fi

# (2) Ensure that the runtime option is appropriate.
if [[ ! "$STOP_OPTION" =~ ^(ndays|nmonths)$ ]]; then 
    echo "ERROR: $STOP_OPTION not valid stop option. Please use 'ndays' or 'nmonths'."
    exit 1
fi

# (3) Check that default settings have been changed.
if [ ${pcode} == "ACCOUNT" ]; then
    echo "Please input an account to charge."
    exit 1
fi

if [ ${E3SM_DIR} == "/path/to/E3SM/directory" ]; then
    echo "Please input the E3SM directory under E3SM_DIR."
    exit 1
fi

# Output sampling. Editing the sampling here before anything else since we
# are directly modifying a Registry file.
appendSensor=""
if (( nvertlevels != 0 ))
then
    registry_dir=${E3SM_DIR}/components/mpas-source/src/core_ocean/analysis_members/Registry_lagrangian_particle_tracking.xml
    if ${sampleTemperature}; then
        echo "Sample Temperature: TRUE"
        appendSensor=${appendSensor}Ton
    else
        echo "Sample Temperature: FALSE"
        appendSensor=${appendSensor}Toff
    fi
    if ${sampleSalinity}; then
        echo "Sample Salinity: TRUE"
        appendSensor=${appendSensor}.Son
    else
        echo "Sample Salinity: FALSE"
        appendSensor=${appendSensor}.Soff
    fi
    if ${BGC}; then
        if ${sampleDIC}; then
            echo "Sample DIC: TRUE"
            appendSensor=${appendSensor}.DICon
        else
            echo "Sample DIC: FALSE"
            appendSensor=${appendSensor}.DICoff
        fi
        if ${sampleALK}; then
            echo "Sample ALK: TRUE"
            appendSensor=${appendSensor}.ALKon
        else
            echo "Sample ALK: FALSE"
            appendSensor=${appendSensor}.ALKoff
        fi
        if ${samplePO4}; then
            echo "Sample PO4: TRUE"
            appendSensor=${appendSensor}.PO4on
        else
            echo "Sample PO4: FALSE"
            appendSensor=${appendSensor}.PO4off
        fi
        if ${sampleNO3}; then
            echo "Sample NO3: TRUE"
            appendSensor=${appendSensor}.NO3on
        else
            echo "Sample NO3: FALSE"
            appendSensor=${appendSensor}.NO3off
        fi
        if ${sampleSiO3}; then
            echo "Sample SiO3: TRUE"
            appendSensor=${appendSensor}.SiO3on
        else
            echo "Sample SiO3: FALSE"
            appendSensor=${appendSensor}.SiO3off
        fi
        if ${sampleNH4}; then
            echo "Sample NH4: TRUE"
            appendSensor=${appendSensor}.NH4on
        else
            echo "Sample NH4: FALSE"
            appendSensor=${appendSensor}.NH4off
        fi
        if ${sampleFe}; then
            echo "Sample Fe: TRUE"
            appendSensor=${appendSensor}.Feon
        else
            echo "Sample Fe: FALSE"
            appendSensor=${appendSensor}.Feoff
        fi
        if ${sampleO2}; then
            echo "Sample O2: TRUE"
            appendSensor=${appendSensor}.O2on
        else
            echo "Sample O2: FALSE"
            appendSensor=${appendSensor}.O2off
        fi
    fi
    python py/update_particle_sampling.py --file ${registry_dir} -t ${sampleTemperature} \
        -s ${sampleSalinity} -d ${sampleDIC} -a ${sampleALK} -p ${samplePO4} \
        -n ${sampleNO3} -i ${sampleSiO3} --NH4 ${sampleNH4} -e ${sampleFe} \
        -o ${sampleO2}
fi

# ----------------------
# CASE SETUP 
# ----------------------
echo "Setting up case..."
echo "------------------"

HOMEDIR=`pwd`

cd ${E3SM_DIR}/cime/scripts
# Set casename dependent on BGC-active or physics-only
if ${BGC}
then
    echo "USER HAS ELECTED FOR OCEAN BIOGEOCHEMISTRY"
    casename=GMPAS-OECO-ODMS-IAF
else
    echo "USER HAS ELECTED FOR PHYSICS-ONLY"
    casename=GMPAS-IAF
fi
casename=${casename}.${res}.${mach}.${nproc_ocean}o.${nproc_ice}i
if (( nvertlevels == 0 )) 
then
    casename=${casename}.noParticles
    PARTICLES=false
    echo "USER HAS ELECTED TO HAVE NO PARTICLES IN THIS RUN."
else
    casename=${casename}.${nvertlevels}ParticleLayers
    PARTICLES=true
    echo "USER HAS ELECTED FOR GLOBAL SEEDING WITH ${nvertlevels} VERTICAL LAYERS."
    # Add sensor declarations
    casename=${casename}.${appendSensor}
fi 

# check if case exists to avoid overwrite.
if [ -d "../../$casename" ]
then
    echo "ERROR: Specified case already exists."
    echo "Would you like to delete the case folder and continue?"
    read -p "Continue? (Y/N): " confirm
    if [ $confirm == 'Y' ]; then
        rm -rf ${E3SM_DIR}/${casename}
    else
        exit 1
    fi
fi

if ${BGC}
then
    ./create_newcase -s --case ../../${casename} --compset GMPAS-OECO-ODMS-IAF --res ${res} \
        --mach ${mach} --compiler gnu --mpilib openmpi --project ${pcode} \
        --input-dir ${input_dir}
else
    ./create_newcase -s --case ../../${casename} --compset GMPAS-IAF --res ${res} \
        --mach ${mach} --compiler gnu --mpilib openmpi --project ${pcode} \
        --input-dir ${input_dir}
fi
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
if [ ${mach} == "grizzly" ] || [ ${mach} == "wolf" ]; then
  echo "Editing env_mach_specific..."
  python py/update_env_mach_specific.py --file ${E3SM_DIR}/${casename}/env_mach_specific.xml 
fi

# Case setup
cd ${E3SM_DIR}/${casename}
echo "Setting up case directory..."
./case.setup -s

# Add particle files to case folder. 
# Parameter expansion to find run directory
RUNDIR=$(./xmlquery --value CIME_OUTPUT_ROOT)
RUNDIR=${RUNDIR%/*}
RUNDIR=${RUNDIR}/cases/${casename}/run

# ----------------------
# PARTICLE CONFIGURATION 
# ----------------------
if ${PARTICLES}; then
    mkdir particles
    echo "Adding LIGHT utilities to case directory..."
    cp ${E3SM_DIR}/components/mpas-source/testing_and_setup/compass/utility_scripts/LIGHTparticles/* particles

    # Copy user_nl_mpaso into main directory
    # NOTE : Need to add supercycling and RK functionality here.
    echo "Editing streams.ocean file..."
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

    # Append sensor output to streams file
    echo "Appending sensor output to streams.ocean..."
    python py/add_sensors_to_streams.py --file ${E3SM_DIR}/${casename}/SourceMods/src.mpaso/streams.ocean \
        -t ${sampleTemperature} -s ${sampleSalinity} -d ${sampleDIC} -a ${sampleALK} \
        -p ${samplePO4} -n ${sampleNO3} -i ${sampleSiO3} --NH4 ${sampleNH4} \
        -e ${sampleFe} -o ${sampleO2}

    # Build particle file
    # get init and graph file
    python py/assist_particle_build.py --stream ${E3SM_DIR}/${casename}/SourceMods/src.mpaso/streams.ocean \
        --graph ${input_dir}/ocn/mpas-o/${res#*_} -p ${nproc_ocean} \
        -o ${HOMEDIR}
    graph=`cat temp_graph`
    init=`cat temp_init`
    rm temp_graph
    rm temp_init

    # parse particle types
    parttype=''
    for val in "${particletype[@]}"; do 
        if [ -z "$parttype" ]; then 
            parttype=$val 
        else parttype=$parttype,$val 
    fi done

    # Build particle file
    cd ${E3SM_DIR}/${casename}/particles
    python make_particle_file.py -i ${init} -g ${graph} -p ${nproc_ocean} -t ${parttype} \
        --nvertlevels ${nvertlevels} -o ${RUNDIR}/particles.nc
fi

# If 30to10 case and BGC, need to append proper surface fluxes to streams.ocean file.
if [[ ${BGC} && ${res} == "T62_oRRS30to10v3" ]]; then
  # If there are no particles, then streams.ocean hasn't been copied to SourceMods yet.
  if [ ${PARTICLES} == false ]; then
      cd ${E3SM_DIR}/${casename}
      cp ${RUNDIR}/streams.ocean SourceMods/src.mpaso
  fi
  cd ${HOMEDIR}
  cp txt/ecosys_monthly_flux temp_ecosys_monthly_flux
  python py/add_surface_flux_30to10.py --source temp_ecosys_monthly_flux \
      --dest ${E3SM_DIR}/${casename}/SourceMods/src.mpaso/streams.ocean
  rm temp_ecosys_monthly_flux
fi

# ------------------
# BUILD RUN
# ------------------
echo "Building case..."
echo "------------------"
cd ${E3SM_DIR}/${casename}
./case.build

# Set wallclock, runtime, etc.
echo "Setting wallclock time to ${WALLCLOCK}..."
./xmlchange -s --file env_batch.xml JOB_WALLCLOCK_TIME=${WALLCLOCK}

if [ ${STOP_OPTION} == 'ndays' ]; then
    echo "Setting run length to ${STOP_N} days..."
elif [ ${STOP_OPTION} == 'nmonths' ]; then
    echo "Setting run length to ${STOP_N} months..."
fi
./xmlchange -s --file env_run.xml STOP_OPTION=${STOP_OPTION}
./xmlchange -s --file env_run.xml STOP_N=${STOP_N}

# ------------------
# SUBMIT CASE 
# ------------------
read -p "Would you like to submit the job now? (Y/N): " confirm
if [ ${confirm} == 'Y' ]; then
    echo "SUBMITTING JOB..."
    ./case.submit
else
    echo "Exiting setup. Use ./case.submit to submit your job."
    exit 0
fi
