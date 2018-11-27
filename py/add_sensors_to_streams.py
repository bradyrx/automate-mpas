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


def main(filepath, temperature, salinity, DIC, ALK):
    tree = et.parse(filepath)
    root = tree.getroot()
    streams = root.findall('stream')
    append_streams(streams, 'particleTemperature', temperature)
    append_streams(streams, 'particleSalinity', salinity)
    append_streams(streams, 'particleDIC', DIC)
    append_streams(streams, 'particleALK', ALK)
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
    args = vars(ap.parse_args())
    filepath = args['file']
    temperature = str2bool(args['temperature'])
    salinity = str2bool(args['salinity'])
    DIC = str2bool(args['DIC'])
    ALK = str2bool(args['ALK'])
    main(filepath, temperature, salinity, DIC, ALK)
