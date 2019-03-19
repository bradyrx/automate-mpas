import argparse
import fileinput


def main(f_in, supercycle):
    f = fileinput.FileInput(f_in, inplace=True, backup=None)
    for line in f:
        print(line.replace("'dt'", "'" + supercycle + "'"))
    f.close()


if __name__ == '__main__':
    ap = argparse.ArgumentParser(
        description="Updates ocean namelist for supercycling.")
    ap.add_argument('-i', '--input', required=True, type=str)
    ap.add_argument('-s', '--supercycle', required=True, type=str)
    args = vars(ap.parse_args())
    f_in = args['input']
    supercycle = args['supercycle']
    main(f_in, supercycle)
