#!/usr/bin/env bash 

# Current script location.
 
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/ena.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 LIBRARY OUTPUT_DIRECTORY"
    exit 1
fi

library=$1
outputDirectory=$2

check_variables "library" "outputDirectory"

# Construct library paths for remote and local

subDir=`get_library_subdir $library`

# Create local directory for FASTQ file - if it doesn't already exist

localFastqDir=${outputDirectory}/$subDir
mkdir -p $localFastqDir
chmod -R g+w $(dirname $outputDirectory)

# Get all files for the library with rsync

`fetch_ena_sudo_string` rsync -ssh -avh --no-p ${ENA_NODE}:${ENA_ROOT_DIR}/${subDir}/ ${outputDirectory}/$subDir > /dev/null 2>&1
errCode=$?

if [ $errCode -ne 0 ]; then 
    echo "$library file download failed (err code $errCode)"
    exit 1
else
    echo "$library files downloaded successfully to ${outputDirectory}/$subDir"
    exit 0
fi
