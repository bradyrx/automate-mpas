# Append streams.ocean 
# -------------------------
# Author : Riley X. Brady
# Date   : Nov. 13th, 2018
# -------------------------
# This serves to append the LIGHT streams to the streams.ocean file for
# the run
from lxml import etree as et
import argparse


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


def main():
    ap = argparse.ArgumentParser(
            description="Adds Lagrangian streams to main streams.ocean file.")
    ap.add_argument('-s', '--source', required=True, type=str,
            help="Location of source xml (i.e. streams.ocean.lagr)")
    ap.add_argument('-d', '--dest', required=True, type=str,
            help="Location of destination xml (i.e. streams.ocean)")
    ap.add_argument('-p', '--particle', required=True, type=str,
            help="Location of particle init file.")
    ap.add_argument('--outputfreq', required=True, type=int,
            help="Frequency to output particles (in days, currently only int)")
    args = vars(ap.parse_args())
    src = args['source']
    dest = args['dest']
    particle = args['particle']
    outputfreq = args['outputfreq']
   
    # Append contents of Lagrangian streams to main ocean stream.
    add_root(src)
    src_tree = et.parse(src)
    src_root = src_tree.getroot()
    dest_tree = et.parse(dest)
    dest_root = dest_tree.getroot()
    # Ensure to append after the last stream before auxillary
    parent = dest_root.findall('stream')[-2]
    lagr_streams = src_root.findall('stream')
    for stream in reversed(lagr_streams):
        parent.addnext(stream)
    # Update location of particle file and output frequency.
    dest_streams = dest_root.findall('stream')
    for stream in dest_streams:
        if stream.get('name') == 'lagrPartTrackInput':
            stream.set('filename_template', particle)
        if stream.get('name') == 'lagrPartTrackOutput':
            if outputfreq < 10:
                interval = '00-00-0' + str(outputfreq) + '_00:00:00'
            else:
                interval = '00-00-' + str(outputfreq) + '_00:00:00'
            stream.set('output_interval', interval)
    et.ElementTree(dest_root).write(dest, pretty_print=True)


if __name__ == '__main__':
    main()
