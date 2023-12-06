"""Download all fastqs in an SRR accession list."""

import argparse
import os
import subprocess
from tqdm import tqdm


def parse_arguments():
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        prog='srr_munch.py',
        usage='%(prog)s -i [input_file] -o [output_dir]',
        description='Download fastq files for a SRR accession list'
    )

    parser.add_argument('-i', '--input',
                        action='store', required=True)
    parser.add_argument('-o', '--output-dir',
                        action='store', required=True)

    return parser.parse_args()


def batch_download(acc_list, output_dir):
    """Open a shell subprocess to download all fastqs into the output."""
    acc_list_file_size = os.path.getsize(acc_list)
    with tqdm(total=acc_list_file_size) as pbar:
        with open(acc_list, 'r', encoding='utf8') as file:
                for line in file:
                    try:
                        cmd = ['fasterq-dump', '-p', '-O', output_dir, line.strip()]
                        subprocess.run(cmd, check=True)
                        # Increment progress bar
                        pbar.update(len(line.encode('utf-8')))

                    except ChildProcessError as error:
                        print(error)

    print(f'Output Directory is: {output_dir}')


if __name__ == '__main__':
    args = parse_arguments()
    batch_download(args.input, args.output_dir)
