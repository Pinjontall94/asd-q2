"""Download all fastqs in an SRR accession list."""

import argparse
import subprocess


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


def batch_download(acc_list: str, output_dir: str):
    """Open a shell subprocess to download all fastqs into the output."""
    with open(acc_list, 'r', encoding='utf8') as file:
        for line in file:
            try:
                subprocess.run([
                    'fasterq-dump', '-O', output_dir, line.strip('\n')
                ], check=True)

            except ChildProcessError as error:
                print(error)

        print(f'Output Directory is: {output_dir}')


if __name__ == '__main__':
    args = parse_arguments()
    batch_download(args.input, args.output_dir)
