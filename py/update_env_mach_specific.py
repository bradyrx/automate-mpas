# Update env_mach_specific
# -------------------------
# Author : Riley X. Brady
# Date   : Nov. 13th, 2018
# -------------------------
# For IC at LANL, one needs to add mkl to the modules loaded in 
# env_mach_specific.xml to get E3SM to run without error.
from xml.etree import ElementTree as ET
import argparse

def main():
    ap = argparse.ArgumentParser(
            description="Adds mkl to the env_mach_specific.xml file in a \
                         ACME case folder.")
    ap.add_argument('-f', '--file', required=True, type=str,
            help="Location of env_mach_specific.xml file")
    args = vars(ap.parse_args())
    filepath = args['file']
    # Append mkl to xml file
    tree = ET.parse(filepath)
    root = tree.getroot()
    ms = root.find('module_system')
    m = ET.SubElement(ms, 'modules')
    mkl = ET.SubElement(m, 'command', attrib={'name': 'load'})
    mkl.text = 'mkl'
    tree.write(filepath)

if __name__ == '__main__':
    main()
