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
nvertlevels=10 # number of particles to seed in the vertical (0 = no particles). NOTE: May need to edit this a bit if user wants only surface particles.
output_frequency=2 # output frequency in days.
# vertseedtype=linear # seed strategy for particles; currently not supported
particletype=(surface passive) # space-separated particle types
SOfilter=false # true to seed only the Southern Ocean with particles

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
