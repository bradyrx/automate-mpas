# Assist Particle Build
# -------------------------
# Author : Riley X. Brady
# Date   : Nov. 13th, 2018
# -------------------------
# This helps to query a few important file paths for building the 
# particle init file.
from lxml import etree as et
import argparse
import glob


def main():
    ap = argparse.ArgumentParser(
            description="Finds file paths for graph and init file to help build particle.")
    ap.add_argument('-s', '--stream', required=True, type=str,
            help="Location of streams.ocean file")
    ap.add_argument('-g', '--graph', required=True, type=str,
            help="Potential location of graph file.")
    ap.add_argument('-p', '--procs', required=True, type=int,
            help="Number of processors.")
    ap.add_argument('-o', '--output', required=True, type=str,
            help="Where to output temp files with directories in them.")
    args = vars(ap.parse_args())
    stream = args['stream']
    graph = args['graph']
    procs = args['procs']
    output = args['output']
    # Grab init file from xml.
    tree = et.parse(stream)
    root = tree.getroot()
    parent = root.find('immutable_stream')
    init = parent.get('filename_template')
    # print to temporary file for shell to read
    with open(output + '/temp_init', 'a') as f:
        f.write(init)
    # Try out potential graph file.
    graph_list = glob.glob(graph + '/*graph*.' + str(procs))
    if len(graph_list) == 1:
        print("Graph file found:")
        print(graph_list[0])
        with open(output + '/temp_graph', 'a') as f:
            f.write(graph_list[0])
    elif len(graph_list) > 1:
        raise ValueError("Conflicting graph files, please resolve.")
    else:
        raise ValueError("GRAPH FILE DOES NOT EXIST FOR THIS PROC LAYOUT AND MESH." +
                "\n" + "PLEASE USE METIS TO PRODUCE ONE.")


if __name__ == '__main__':
    main()
