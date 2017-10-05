import argparse
import textwrap
import os
import re
import collections
import csv
from operator import itemgetter

def check_folder(in_dir, reg_string):
    filelist = []
    for f in os.listdir(in_dir):

        if re.match(reg_string, f, re.IGNORECASE):

            fn, fe = os.path.splitext(f)
            fnl = fn.split("_")
            filename = fn
            fullpth = os.path.join(in_dir, f)
            wells = fnl[0]



            if re.match("^.*pos.*", f, re.IGNORECASE):
                polarity = "pos"
            elif re.match("^.*neg.*", f, re.IGNORECASE):
                polarity = "neg"
            else:
                error_message = "Files need to have either 'pos' or 'neg' in the file name"
                print error_message
                return 1, error_message, "", ""
            if re.match("^.*blank.*", f, re.IGNORECASE):
                sample_type = "blank"
            else:
                sample_type = "sample"


            filelist.append([wells, sample_type, polarity, filename, fullpth])

    return filelist

def get_filelist(filesin, o, file_type='mzML', create_filelist=True):

    filedict = collections.OrderedDict()


    if file_type=="mzML":
        reg_string = "^.*mzML$"
    else:
        reg_string = "^.*raw$"

    if isinstance(filesin, list):
        filelist = []
        for f in filesin:
            filelist.extend(check_folder(f, reg_string))
    else:
        filelist = check_folder(filesin, reg_string)

    # Turn filelist into a dictionary
    for f1 in filelist:
        well = f1[0]
        filedict[well] = []
        for f2 in filelist:
            if well == f2[0]:
                filedict[well].append(f2[1:len(f2)+1])



    filelist = sorted(filelist, key=itemgetter(0, 1))

    for k, v in filedict.iteritems():
        classes = [i[0] for i in v]
        classes.sort()
        if not classes == ['blank', 'sample']:
            error_message = "!!!!ERROR!!!! Blank and sample required for each well, file type {}".format(file_type)
            print error_message
            return 1, error_message, "", ""

    print 'files of type {} checked, files OK'.format(file_type)

    if create_filelist:

        outname = write_filedict(filedict, o, file_type)
        print 'filelist created in folder {}, using file type {}, full path {}'.format(o, file_type, outname)

    return 0, "files OK", filedict, filelist

def write_filedict(filedict, out_dir, file_type, file_spacing='tsv'):

    outname = os.path.join(out_dir,'filelist_{}.{}'.format(file_type, file_spacing))

    if file_spacing=='tsv':
        delim = '\t'
    elif file_spacing=='csv':
        delim = ','
    else:
        delim = ','


    with open(outname, 'wb') as csvfile:
        w = csv.writer(csvfile, delimiter=delim)

        w.writerow(['filename','classLabel', 'multilist', 'multilistLabel'])
        c = 1
        for k, v in filedict.iteritems():
            for i in v:
                w.writerow([os.path.basename(i[3]), i[0], c, k])
            c +=1

    return outname


def main():

    p = argparse.ArgumentParser(prog='PROG',
                                formatter_class=argparse.RawDescriptionHelpFormatter,
                                description='''Create filelist for DMA DIMS nearline workflow''',
                                epilog=textwrap.dedent('''
                            -------------------------------------------------------------------------

                            Example Usage

                            python dma-filelist-generation.py -i [dir with sample files], [dir with blank files] -o .

                            '''))

    p.add_argument('-i', dest='i', help='dir with sample files',  nargs = '*', required=True)
    p.add_argument('-o', dest='o', help='out dir', required=True)
    p.add_argument('--check_mzml', dest='check_mzml', action='store_true')
    p.add_argument('--check_raw', dest='check_raw', action='store_true')
    p.add_argument('--create_filelist_mzml', dest='create_filelist_mzml', action='store_true')
    p.add_argument('--create_filelist_raw', dest='create_filelist_raw', action='store_true')

    args = p.parse_args()

    if not os.path.exists(args.o):
        os.makedirs(args.o)
    print args.o

    if not args.check_mzml and not args.check_raw:
        print '--check_mzml or --check_raw (or both) are required as inputs'
        exit()

    if args.check_mzml:
        get_filelist(args.i, args.o, file_type='mzML', create_filelist=args.create_filelist_mzml)

    if args.check_raw:

        get_filelist(args.i, args.o, file_type='raw',  create_filelist=args.create_filelist_raw)



if __name__ == '__main__':
    main()

