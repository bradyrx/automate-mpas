#!/bin/bash
# Author : Riley X. Brady
# Date : 03/19/2019 
#
# This is a subscript of the main package script that checks that certain
# python packages are loaded and certain config options are 
# declared.
# ------------------
source ../config.sh

# (1) See if a few critical packages are installed for python.
python -c "import lxml"
if (( $? == 1 )); then
    echo "You must install lxml for python before continuing."
    exit 1  
fi
python -c "import netCDF4"
if (( $? == 1 )); then
    echo "You must install netCDF4 for python before continuing."
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
