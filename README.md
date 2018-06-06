# Common Gene Expression Group functions

Common functions with general utility to Atlas and other activities

## Fetching files from the ENA

Multiple group activities require retrieving files from the ENA, and FTP is slow. We have access via SSH (when sudo'd as fg_atlas). Functions are provided here to facilitate that process. 

* **ena.sh** contains functions for querying files in the ENA. 
* **fetchFASTQFromENA.sh** is a script for downloading all files for a library to a specified directory.
* **fetchSdrfFASTQFromENA.sh** wraps **fetchFASTQFromENA.sh** to download FASTQ files for runs in an SDRF file.

To function, an 'ena_credentials.sh' file must be placed in the checkout location for this repository, containing variable definitions like:

```
ENA_NODE=''
ENA_USER=''
ENA_ROOT_DIR=''
```

ENA_NODE is the host name of the ENA machine. ENA_USER is a user name with permission to SSH to that host, which you either are, or to which you can sudo. ENA_ROOT_DIR is the root location on the ENA host machine where the fastq files are stored.

### Fetch a single fastq file using its FTP link

It's handy to supply an FTP link and have the link converted to a file path and retrieved. Do so like:

```
fetchEnaFastqFtpUriViaSsh.sh ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR510/002/SRR5101952/SRR5101952_2.fastq.gz SRR5101952_2.fastq.gz
```

### Fetch run fastq files from the ENA

```
fetchFASTQFromENA.sh SRR5102087 scratch no
```

This will download FASTQ files for run SRR5102087 to the directory 'scratch'. By default, this will create subdirectory structure mirroring that in the ENA, e.g. SRR510/007/SRR5102087, but to disable this and place all files in the top level of the target directory use the third argument, setting its value to anything other than 'yes'.

### Fetch all run fastq files for runs in an SDRF

```
sh fetchSdrfFASTQFromENA.sh E-ENAD-14.sdrf.txt ManuallyDownloaded/E-ENAD-14
```


