#!/usr/bin/env bash 

# Current script location.
 
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/ena.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 SDRF_FILE OUTPUT_DIRECTORY [ENA_STRUCTURE_AT_OUTPUT? (yes/no)]"
    exit 1
fi

sdrfFile=$1
outputDirectory=$2
enaStructureAtOutput=${3:-yes}

# Parse runs from the SDRF and download libraries

runs=`get_ENA_runs_from_sdrf $sdrfFile`
if [ $? -ne 0 ]; then
    echo $runs
    exit 1
fi

# Download files for all the runs we've found

echo -e "$runs" | while read -r l; do
    sh $scriptDir/fetchFASTQFromENA.sh $l $outputDirectory no
done
