# Add sensors to streams
# -------------------------
# Author : Riley X. Brady
# Date   : Nov. 27th, 2018
# -------------------------
# This appends particle sensor output to the streams.ocean file.
from lxml import etree as et
import argparse


def str2bool(v):
    if v.lower() in ['yes', 'true', 't', 'y', '1']:
        return True
    if v.lower() in ['no', 'false', 'f', 'n', '0']:
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


def append_streams(streams, variable, logical):
    """
    Loops through streams, finds LIGHT output, appends particle variable
    if true.
    """
    for stream in streams:
        if stream.get('name') == 'lagrPartTrackOutput':
            if logical:
                newvar = et.Element('var', name=variable)
                stream.append(newvar)


def main(filepath, temperature, salinity, DIC, ALK, PO4, NO3, SiO3, NH4,
         Fe, O2):
    tree = et.parse(filepath)
    root = tree.getroot()
    streams = root.findall('stream')
    append_streams(streams, 'particleTemperature', temperature)
    append_streams(streams, 'particleSalinity', salinity)
    append_streams(streams, 'particleDIC', DIC)
    append_streams(streams, 'particleALK', ALK)
    append_streams(streams, 'particlePO4', PO4)
    append_streams(streams, 'particleNO3', NO3)
    append_streams(streams, 'particleSiO3', SiO3)
    append_streams(streams, 'particleNH4', NH4)
    append_streams(streams, 'particleFe', Fe)
    append_streams(streams, 'particleO2', O2)
    et.ElementTree(root).write(filepath, pretty_print=True)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(
            description="Adds particle sensor output to streams.ocean file.")
    ap.add_argument('-f', '--file', required=True, type=str,
            help="Location of streams.ocean file.")
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
    ap.add_argument('-f', '--Fe', required=True, type=str,
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
