# Automate MPAS Simulation

### Author: Riley X. Brady
### Contact: riley.brady@colorado.edu

A set of scripts to automate the process of setting up, building, and submitting an MPAS-Ocean case with or without particles.

## Installation

1. Run `git clone git@github.com:bradyrx/automate_mpas_simulation.git` on an institutional computer (Grizzly and Wolf tested at LANL).

2. Add folder to your E3SM directory. Make sure that a version of MPAS with particles is checked out. E.g., check out the `particlePassiveFloatVerticalTreatmentFix` branch from https://github.com/pwolfram/MPAS-Model.

3. Load a python2.7 virtual environment and make sure `lxml` is installed.

4. Edit the header variables in `generate_E3SM_case.sh` to set resolution, machine, p-code, particle count, etc.

5. Run `bash generate_E3SM_case.sh`
