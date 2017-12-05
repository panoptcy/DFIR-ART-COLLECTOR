# DFIR ART COLLECTOR
DFIR ART COLLECTOR or Digtial Forensics and Incident Response ARTifact COLLECTOR is a collection of scripts and tools that automate the collection of useful artifacts for digital forensics and incident response work. DFIR ART COLLECTOR starts by pulling the most volatile evidence first then produces down to less volatile artifacts until finally creating a disk image using FTK Imager. For more information on DFIR ART COLLECTOR please see my [blog](https://bitsbybrandon.com/introducing-dfir-art-collector).

## Install
Due to licensing concerns two tools are omited from this repo, they are the commandline version of AccessData's FTK Iamger and Microsoft's Sysinternals. For the scripts to work correctly, please download Microsoft's [Sysinternal Suite](https://download.sysinternals.com/files/SysinternalsSuite.zip) and extract all the tools into the tools\win\SysinternalsSuite directory. If you also wish to collect the raw drive image you will also need to download the commandline version of AccessData's [FTK Iamger](https://ad-zip.s3.amazonaws.com/FTKImager.3.1.1_win32.zip) and extract the files to the tools\win\access_data directory.

## Usage
To run DFIR ART COLLECTOR you simply need to run the batch script as an administrator from the commandline with the following arguments:

dfir-art-collector.bat \[path\to\the\tools\directory] [path\to\store\evidence] [drive_number_to_image]

For more information on usage please see my [blog](https://bitsbybrandon.com/introducing-dfir-art-collector).

## Change Log
2017-12-5 Uploaded version 1.0.0
