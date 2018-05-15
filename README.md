# Common Gene Expression Group functions

Common functions with general utility to Atlas and other activities

## Fetching files from the ENA

Multiple group activities require retrieving files from the ENA, and FTP is slow. We have access via SSH (when sudo'd as fg_atlas). Functions are provided here to facilitate that process. 

* **ena.sh** contains functions for querying files in the ENA. 
* **fetchFASTQFromENA.sh** is a script for downloading all files for a library to a specified directory.

To function an 'ena_credntials.sh' file must be placed in the checkout location for this repository, containing variable definitions like:

```
ENA_NODE=''
ENA_USER=''
ENA_ROOT_DIR=''
```

ENA_NODE is the host name of the ENA machine. ENA_USER is a user name with permission to SSH to that host, which you either are, or to which you can sudo. ENA_ROOT_DIR is the root location on the ENA host machine where the fastq files are stored.
