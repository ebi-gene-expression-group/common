#!/usr/bin/env bash 

# Current script location.
 
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/ena.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 FTP_URI [OUTPUT_FILE]"
    exit 1
fi

ftp_uri=$1
target_local_filename=$2

if [ -z "$target_local_filename" ]; then
    target_local_filename=$(basename $ftp_uri)
fi
    
if [ -e "$target_local_filename" ]; then
    echo "Local file name $target_local_filename already exists"
    exit 1;
fi

if [[ $ftp_uri =~ .*ftp.sra.ebi.ac.uk.* ]]; then 
    ena_file_path=`convert_ena_fastq_to_path $ftp_uri`
    fetch_file_from_ena $ena_file_path $target_local_filename  
else
    echo "File is not ENA- just wget'ing"
    wget  -nv -c $url -O $target_local_filename.tmp && mv $target_local_filename.tmp $target_local_filename  
fi
