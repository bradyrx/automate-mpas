# Automate MPAS Simulation

### Author: Riley X. Brady
### Contact: riley.brady@colorado.edu

A set of scripts to automate the process of setting up, building, and submitting an MPAS-Ocean case with or without particles.

## Installation

1. Run `git clone git@github.com:bradyrx/automate_mpas_simulation.git` on an institutional computer (Grizzly and Wolf tested at LANL).

2. Add folder to your E3SM directory. Make sure that a version of MPAS with particles is checked out. E.g., check out the `particlePassiveFloatVerticalTreatmentFix` branch from https://github.com/pwolfram/MPAS-Model. It is crucial to have the bleeding edge checked out to have functionality for all BGC sensors.

3. Load a python2.7 virtual environment and make sure `lxml` is installed.

4. Edit the header variables in `generate_E3SM_case.sh` to set resolution, machine, p-code, particle count, etc.

5. Run `bash generate_E3SM_case.sh`

## METIS Mesh Generation

Note that when running the script with `nproc_ocean` and `nproc_ice` set, you need to have graph files built for these number of processors. The graph file has to live in the input directory you specify. 

Load METIS module on IC:

`module use /usr/projects/climate/SHARED_CLIMATE/modulefiles/all`

`module load metis`

Then run the following command:

`gpmetis graph_file nproc`

Where `graph_file` is the base graph_file for that mesh and `nproc` is the number of processors you desire.

## Shell Script Options

The user should only need to modify header variables in the main `automate_mpas_simulation.sh` script.

At a minimum, `E3SM_DIR` should be changed to the direct path to the base E3SM folder and `pcode` should be changed to the appropriate account/project code.

### Model Configuration

Options pertaining to the model setup.

| Option      |  Description                                     | Example Values                    |
|-------------|--------------------------------------------------|-----------------------------------|
| BGC         | Whether or not to run with ocean biogeochemistry | true/false                        |
| res         | MPAS-Ocean grid resolution                       | T62_oEC60to30v3, T62_oRRS30to10v3 |
| nproc_ocean | Number of processors for ocean                   | 512                               |
| nproc_ice   | Number of processors for ice                     | 128                               |
| mach        | IC machine name                                  | grizzly, wolf                     |
| pcode       | Project account                                  | w19_marinebgc                     |
| input_dir   | Input directory for initialization data          | filepath                          |

### Run Configuration

Options pertaining to job submission and run time.

| Option      |  Description                                                   | Example Values |
|-------------|----------------------------------------------------------------|----------------|
| WALLCLOCK   | Wallclock time for this run                                    | hh:mm:ss       |
| STOP_OPTION | Whether to run N days or N months                              | ndays, nmonths |
| STOP_N      | Number of days or months to run (dependent on previous option) | 5              |

### Particle Configuration

Options pertaining to particle setup.

| Option           |  Description                                                        | Example Values              |
|------------------|---------------------------------------------------------------------|-----------------------------|
| nvertlevels      | Number of vertical levels for particle seeding (if 0, no particles) | 10                          |
| output_frequency | Frequency to save out particle trajectories in days                 | 2                           |
| particletype     | Particle seeding strategies, space-separated and bounded by ()      | surface, passive, isopycnal |

### Particle Sensor Configuration

Options pertaining to sensors on board the e-floats.

**NOTE**: The only current way to turn on sensors is to directly modify the source Registry in the MPAS-O directory. It currently cannot be changed via `user_nl_mpaso`. Thus, check your LIGHT Registry when submitting jobs in the future if you aren't using this script to make sure you have the appropriate registry booleans set.

| Option            |  Description                                                          | Example Values |
|-------------------|-----------------------------------------------------------------------|----------------|
| sampleTemperature | If true, save out temperature along float trajectory                  | true/false     |
| sampleSalinity    | If true, save out salinity along float trajectory                     | true/false     |
| sampleDIC         | If true, save out DIC along float trajectory (only runs if BGC is on) | true/false     |
| sampleALK         | If true, save out ALK along float trajectory (only runs if BGC is on) | true/false     |
| samplePO4         | If true, save out PO4 along float trajectory (only runs if BGC is on) | true/false     |
| sampleNO3         | If true, save out NO3 along float trajectory (only runs if BGC is on) | true/false     |
| sampleSiO3         | If true, save out SiO3 along float trajectory (only runs if BGC is on) | true/false     |
| sampleNH4         | If true, save out NH4 along float trajectory (only runs if BGC is on) | true/false     |
| sampleFe         | If true, save out Fe along float trajectory (only runs if BGC is on) | true/false     |
| sampleO2         | If true, save out O2 along float trajectory (only runs if BGC is on) | true/false     |

