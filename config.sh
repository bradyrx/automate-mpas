#---------------------#
#    CONFIG FILE
#---------------------#
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
PARTICLES_ON=false # switch to true for all below options to take effect.

# PARTICLE INITIALIZATION
particletype=(surface passive) # space-separated particle types
nvertlevels=10 # number of particles to seed in the vertical (0 = no particles). NOTE: May need to edit this a bit if user wants only surface particles.
vertseedtype='linear' # seed strategy for particles; choose one of ('linear', 'log', 'denseCenter')
downsample=0 # levels of downsampling (coarsening)
SOfilter=false # true to seed only the Southern Ocean with particles

# PARTICLE COMPUTATION
supercycle=false # To turn on, input valid date string, e.g. '0000_02:00:00' for 2-hour supercycling.

# PARTICLE I/O
output_frequency=2 # output frequency in days.

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
