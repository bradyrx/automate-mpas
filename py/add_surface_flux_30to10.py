# Append streams.ocean 
# -------------------------
# Author : Riley X. Brady
# Date   : Dec 17th, 2018
# -------------------------
# This appends the appropriate BGC surface fluxes to the end of streams.ocean
# for a 30to10 run.
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


def main(source, dest):
    add_root(src)
    src_tree = et.parse(src)
    src_root = src_tree.getroot()
    dest_tree = et.parse(dest)
    dest_root = dest_tree.getroot()
    # Make sure to append after the last stream before auxillary
    parent = dest_root.findall('stream')[-2]
    flux_stream = src_root.find('stream')
    parent.addnext(flux_stream)
    et.ElementTree(dest_root).write(dest, pretty_print=True)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(
            description="Adds 30to10km BGC surface fluxes to streams.ocean")
    ap.add_argument('-s', '--source', required=True, type=str,
            help="Location of source xml (i.e. ecosys_monthly_flux)")
    ap.add_argument('-d', '--dest', required=True, type=str,
            help="Location of destination xml (i.e. streams.ocean)")
    args = vars(ap.parse_args())
    src = args['source']
    dest = args['dest']
    main(src, dest)
