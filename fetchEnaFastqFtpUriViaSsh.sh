#!/usr/bin/env bash 

# Current script location.
 
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/ena.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 FTP_URI OUTPUT_FILE"
    exit 1
fi

ftp_uri=$1
target_local_filename=$2
    
if [ -e "$target_local_filename" ]; then
    echo "Local file name $target_local_filename already exists"
    exit 1;
fi

ena_file_path=`convert_ena_fastq_to_path $ftp_uri`
fetch_file_from_ena $ena_file_path $target_local_filename   
