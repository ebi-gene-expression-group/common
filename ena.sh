# Necessary connection variables for ENA host

# Get FASTQ library path in ENA or ENCODE ENA rule : If the number part is
# greater than 1,000,000 then create an extra subdirectory with numbers
# extracted from the 7th number onwards and zero padded on the left ENCODE
# rule: the path is ${library:0:6}/${library}

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
credentialsFile=$scriptDir/ena_credentials.sh

if [ ! -n "$credentialsFile" ]; then
    echo -e "Please supply a protected credentials file at $scriptDir. This should be a bash file defining ENA_USER, ENA_NODE and ENA_ROOT_DIR"  
    return 1
fi

source $scriptDir/ena_credentials.sh

get_library_subdir() {
    local library=$1
    local forceShortForm=${2:-''} # Abandon extended logic- e.g. for private ArrayExpress submissions

    local subDir=${library:0:6}
    local prefix=
    if ! [[ $subDir =~ "ENC" ]] && [[ -z "$forceShortForm" ]] ; then
        local num=${library:3}
        if [ $num -gt 1000000 ]; then
            prefix="00${library:9}/"
        fi 
    fi
    echo "${subDir}/${prefix}${library}"
}

# Check a list of variables are set

check_variables() {
    vars=("$@")

    for variable in "${vars[@]}"; do
        local value=${!variable}        
        if [ -z $value ]; then
            echo "ERROR: $variable not set";
            return 1
        fi
    done

    return 0
}

# Check we can sudo to a user

check_sudo() {
    sudoUser=$1

    sudo -u $1 echo "Hi!" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "Couldn't sudo to sudoUser"
        exit 1
    fi
}

# Use SSH to check if the file is in ENA. Note that the '-n' is important,
# because any 'while read' loops calling this script use STDIN, which SSH will
# consume otherwise.

check_file_in_ena() {
    local enaFile=$1

    `fetch_ena_sudo_string`ssh -n ${ENA_NODE} "ls ${enaFile}" > /dev/null 2>&1 
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Fetch a file from the ENA to a location

fetch_file_from_ena() {
    local enaFile=$1
    local destFile=$2

    check_variables "flub" "enaFile" "destFile"
    
    echo "Downloading remote file $enaFile to $destFile"

    `fetch_ena_sudo_string` rsync -ssh -avc ${ENA_NODE}:$enaFile $destFile
    if [ $? -ne 0 ] || [ ! -s $destFile ] ; then
        echo "Failed to retrieve $enaFile to $destFile" >&2
        exit 3
    fi
}

# Get a string to sudo as necessary

fetch_ena_sudo_string() {
    # Check if we need to sudo, and if we can

    currentUser=`whoami`
    if [ $currentUser != $ENA_USER ]; then
        check_sudo $ENA_USER
        sudoString="sudo -u $ENA_USER "
    else
        sudoString=""
    fi

    echo $sudoString
}

# Get a list of all the files present for a given library

get_ena_library_files() {
    local library=$1
    local libDir=$(dirname `get_library_path $library`)

    `fetch_ena_sudo_string` ssh -n ${ENA_NODE} ls ${ENA_ROOT_DIR}/$libDir/*
}

