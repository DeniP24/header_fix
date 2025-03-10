Scripts to fix broken filterbank headers by replacing them with neighbouring beam filterbank headers, and the relevant start mjd's.

## Usage:
1. List all filterbank files in a specific path
find path/ -type f -name "*.fil" > all_fils.txt
2. Make a list of broken filterbank files 
./check_broken.sh in trapum_pulsarx_fold_docker_20220411.sif shell
3. Get the tstamps of all fils in all subfolders in “root_base_dir”. This script creates a text file that has Subfolder Path,Tstamps, and Cfbfs that have the same tstamps. It groups them by cfbfs that have the same tstamps. 
./get_tstamps.sh
4. Get the headers to replace the broken headers by
./replacement_headers.sh
5. Get the tstamps to replace the broken header tstamp by
python3 replacement_tstamps.py
6. Create 1 file with damaged headers, replacement headers and replacement tstamps. 
paste damaged_headers.txt_all replacement_headers.txt 4tstamps.txt > Headers_replacements_tstamps.txt