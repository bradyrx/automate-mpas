#!/bin/bash
# Author : Riley X. Brady
# Date : 03/19/2019 
#
# This names the case based on various flags that are turned on and off.
# ------------------
source config.sh
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

