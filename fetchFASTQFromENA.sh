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
enaStructureAtOutput=${3:-yes}

check_variables "library" "outputDirectory"

# Get the ENA-like subdirectory structure

subDir=`get_library_subdir $library`

# Create local directory for FASTQ file - if it doesn't already exist

if [ $enaStructureAtOutput = 'yes' ]; then
    localFastqDir=${outputDirectory}/$subDir
else
    localFastqDir=${outputDirectory}
fi

mkdir -p $localFastqDir
chmod -R g+w $localFastqDir

# Get all files for the library with rsync

`fetch_ena_sudo_string` rsync -ssh -avh --no-p ${ENA_NODE}:${ENA_ROOT_DIR}/${subDir}/ $localFastqDir > /dev/null 2>&1
errCode=$?

if [ $errCode -ne 0 ]; then 
    echo "$library file download failed (err code $errCode)"
    exit 1
else
    echo "$library files downloaded successfully to ${outputDirectory}/$subDir"
    exit 0
fi
