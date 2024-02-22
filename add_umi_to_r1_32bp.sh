#!/bin/bash
#
# Copyright (C): 2019 - Gert Hulselmans
#
# Purpose: Backup all FASTQ files in ngs_runs to archive.


add_umi_to_r1 () {
    local fastq_R2_filename="${1}";
    local fastq_R3_filename="${2}";
    local fastq_R2_and_R3_filename="${3}";


    if [ "${#@}" -ne 3 ] ; then
        printf 'Usage: add_umi_to_r1 fastq_R1_filename fastq_R2_filename fastq_R1_new_filename\n';
        return 1;
    fi

    mawk \
        -v fastq_R2_filename=${fastq_R2_filename} \
        -v fastq_R3_filename=${fastq_R3_filename} \
        -v fastq_R2_and_R3_filename=${fastq_R2_and_R3_filename} \
        '
        BEGIN {
            # Construct command to read R2 and R3 FASTQ file.
            read_fastq_R2_cmd = "zcat " fastq_R2_filename;
            read_fastq_R3_cmd = "zcat " fastq_R3_filename;

            # Construct command to write combined R2 and R3 FASTQ file.
            write_fastq_R2_and_R3_cmd = "pigz > " fastq_R2_and_R3_filename;

            fastq_line_number = 0;

            # Read FASTQ R2 file
            while ( (read_fastq_R2_cmd | getline fastq_R2_line) > 0 ) {
                fastq_line_number += 1;
                fastq_part = fastq_line_number % 4;

                if ( (read_fastq_R3_cmd | getline fastq_R3_line) > 0 ) {
                    if ( fastq_part == 1 ) {
                        # Extract read name from both FASTQ files.
                        read_name_R2 = substr(fastq_R2_line, 2, index(fastq_R2_line, " ") - 2);
                        read_name_R3 = substr(fastq_R3_line, 2, index(fastq_R3_line, " ") - 2);

                        # Check if read names match between both files.
                        if ( read_name_R2 != read_name_R3 ) {
                            print "Error: Read name R2 (\"" read_name_R2 "\") and R3 (\"" read_name_R3 "\") are not paired properly (line number: " fastq_line_number ")."
                            exit(1);
                        }

                        # Write FASTQ R2 read name line.
                        print fastq_R2_line | write_fastq_R2_and_R3_cmd;
                    } else if ( fastq_part % 2 == 0 ) {
                        # Combine FASTQ R2 and R3 sequences (line 2) or quality scores (line 4) together.
                        # Extract 9b from R3 and append to R2.
                        print substr(fastq_R2_line, 1, 32) substr(fastq_R3_line, 1, 9) | write_fastq_R2_and_R3_cmd;
                    } else {
                        # Write line 3 of FASTQ section.
                        print "+" | write_fastq_R2_and_R3_cmd;
                    }
                }
            }

            close(read_fastq_R2_cmd);
            close(read_fastq_R3_cmd);
            close(write_fastq_R2_and_R3_cmd);
        }'
        # #\
        #| gzip \
        #> "${fastq_R2_and_R3_filename}"

}



add_umi_to_r1 "${@}";

