#!/usr/bin/env bash 

# Current script location.
 
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/ena.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 LIBRARY OUTPUT_DIRECTORY [ENA_STRUCTURE_AT_OUTPUT? (yes/no)]"
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

# Get all files for the library with rsync

sudoString=`fetch_ena_sudo_string`
if [ $? -ne 0 ]; then exit 1; fi

# Copy files with sudo'd user as appropriate. Then copy the files to a location
# with the correct user, and remove the old one. This works, while a 'chown'
# would not.

mkdir -p $localFastqDir
TEMPDIR=$(mktemp -d -p $localFastqDir)
chmod g+rwx $TEMPDIR

echo "$sudoString rsync -ssh -avh --no-p --no-o --no-g --omit-dir-times ${ENA_NODE}:${ENA_ROOT_DIR}/${subDir}/ $TEMPDIR"
$sudoString rsync -ssh -avh --no-p --no-o --no-g --omit-dir-times ${ENA_NODE}:${ENA_ROOT_DIR}/${subDir}/ $TEMPDIR > /dev/null 2>&1

errCode=$?

if [ $errCode -ne 0 ]; then 
    echo "$library file download failed (err code $errCode)"
    exit 1
else
    $sudoString chmod ug+rw $TEMPDIR/*
    cp -rp $TEMPDIR/* $localFastqDir && rm -rf $TEMPDIR
    errCode=$?

    if [ $errCode -ne 0 ]; then
        echo "Final copy failed"
        exit 1
    else
        echo "$library files downloaded successfully to ${localFastqDir}"
        exit 0
    
    fi
fi


