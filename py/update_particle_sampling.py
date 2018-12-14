# Append streams.ocean 
# -------------------------
# Author : Riley X. Brady
# Date   : Nov. 27th, 2018
# -------------------------
# This will turn on or off sampling for specific variables, i.e., sensors.
from lxml import etree as et
import argparse


def str2bool(v):
    """
    More accurate parsing of boolean input from command line.
    """
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


def line_prepender(filename, line):
    with open(filename, 'r+') as f:
        content = f.read()
        f.seek(0, 0)
        f.write(line.rstrip('\r\n') + '\n' + content)


def line_appender(filename, line):
    with open(filename, 'a') as f:
        f.write(line)


def add_root(filename):
    """
    The Lagrangian streams file is not a 'real' xml file since there's no
    root to the tree. Need to artificially add that so lxml can read in 
    the file.
    """
    line_prepender(filename, '<root>')
    line_appender(filename, '</root>')


def update_sampling(options, variable, logical):
    """
    Loops through the options xml tags, finds the sampling variable of interest,
    and either turns it on or off.

    "options" is a list of xml tags.
    "variable" is a string of the variable to sample.
    "logical" is a boolean of whether to turn it on or off
    """
    config_name = 'config_AM_lagrPartTrack_sample_' + variable
    for option in options:
        if option.get('name') == config_name:
            if logical:
                option.set('default_value', '.true.')
            else:
                option.set('default_value', '.false.')


def main(filepath, temperature, salinity, DIC, ALK, PO4, NO3, SiO3, NH4,
         Fe, O2):
    add_root(filepath)
    tree = et.parse(filepath)
    root = tree.getroot()
    top_branch = root.find('nml_record')
    options = top_branch.findall('nml_option')
    update_sampling(options, 'temperature', temperature) 
    update_sampling(options, 'salinity', salinity)
    update_sampling(options, 'DIC', DIC)
    update_sampling(options, 'ALK', ALK)
    update_sampling(options, 'PO4', PO4)
    update_sampling(options, 'NO3', NO3)
    update_sampling(options, 'SiO3', SiO3)
    update_sampling(options, 'NH4', NH4)
    update_sampling(options, 'Fe', Fe)
    update_sampling(options, 'O2', O2)
    et.ElementTree(root).write(filepath, pretty_print=True)
    # Remove the root added to top and bottom of file.
    with open(filepath, 'r') as fin:
        data = fin.read().splitlines(True)
    with open(filepath, 'w') as fout:
        fout.writelines(data[1:-1])


if __name__ == '__main__':
    ap = argparse.ArgumentParser(
            description="Turns on or off sampling for specified variables.")
    ap.add_argument('-f', '--file', required=True, type=str,
            help="Location of the LIGHT registry.")
    ap.add_argument('-t', '--temperature', required=True, type=str,
            help="If true, sample temperature.")
    ap.add_argument('-s', '--salinity', required=True, type=str,
            help="If true, sample salinity.")
    ap.add_argument('-d', '--DIC', required=True, type=str,
            help="If true, sample DIC.")
    ap.add_argument('-a', '--ALK', required=True, type=str,
            help="If true, sample ALK.")
    ap.add_argument('-p', '--PO4', required=True, type=str,
            help="If true, sample PO4.")
    ap.add_argument('-n', '--NO3', required=True, type=str,
            help="If true, sample NO3.")
    ap.add_argument('-i', '--SiO3', required=True, type=str,
            help="If true, sample SiO3.")
    ap.add_argument('--NH4', required=True, type=str,
            help="If true, sample NH4.")
    ap.add_argument('-e', '--Fe', required=True, type=str,
            help="If true, sample Fe.")
    ap.add_argument('-o', '--O2', required=True, type=str,
            help="If true, sample O2.")
    args = vars(ap.parse_args())
    filepath = args['file']
    temperature = str2bool(args['temperature'])
    salinity = str2bool(args['salinity'])
    DIC = str2bool(args['DIC'])
    ALK = str2bool(args['ALK'])
    PO4 = str2bool(args['PO4'])
    NO3 = str2bool(args['NO3'])
    SiO3 = str2bool(args['SiO3'])
    NH4 = str2bool(args['NH4'])
    Fe = str2bool(args['Fe'])
    O2 = str2bool(args['O2'])
    main(filepath, temperature, salinity, DIC, ALK, PO4, NO3, SiO3, NH4,
         Fe, O2)
