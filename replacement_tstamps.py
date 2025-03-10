import os
import subprocess
import re
import glob

def main():
    damaged_headers_file = "1damaged_headers.txt_all" #read damaged file
    
    subfolder_paths = [] #read tstamp groups file
    tstamps = []
    cfbfs = []
    with open("2subfolder_tstamp_groups.csv", 'r') as file:
        next(file)
        for line in file:
            # Split on `", "` to separate fields (path, timestamps, cfbfs)
            parts = line.strip().split('", "')
            subfolder_paths.append(parts[0].strip('"'))
            strs=parts[1].strip('"').split(',')
            tstamps.append([float(ts) for ts in strs])
            cfbfs.append(parts[2].strip('"'))
    combined_data = list(zip(subfolder_paths, tstamps, cfbfs))
    with open(damaged_headers_file, 'r') as f:#loop through each line in damaged
        for line in f:
            damaged_file_path = line.strip()
            fil_folder_path = os.path.dirname(damaged_file_path)
            cfbf_folder_path = os.path.dirname(fil_folder_path)
            #This gets the tstamps in this folder
            tstamps_in_folder = []
            names_in_folder = []
            fil_files = [f for f in os.listdir(fil_folder_path) if f.endswith('.fil')]
            for filfile in fil_files:
                singularity_cmd = "singularity exec -B /beegfs:/beegfs /homes/vishnu/singularity_images/trapum_pulsarx_fold_docker_20220411.sif"
                cmd = "{} readfile {}/{} | grep \"start time\" | awk '{{ print $5 }}'".format(singularity_cmd, fil_folder_path, filfile)
                output = subprocess.check_output(cmd, shell=True).strip()
                decoded_output = output.decode('utf-8')
                timestamps = decoded_output.split()
                timestamps = [float(ts) for ts in timestamps]
                tstamps_in_folder.extend(timestamps)
                names_in_folder.append(os.path.basename(filfile).split('_')[2].split('.')[0])
                our_fil_name = os.path.basename(line).split('_')[2].split('.')[0]

            #This finds the tstamp groups in the 3formatted.txt file
            for path, timestamps, cfbfs in combined_data:
                if path == cfbf_folder_path+"/":
                    count = 0 
                    for i in range(len(timestamps)):
                        if round(timestamps[i],12) in tstamps_in_folder:
                            count+=1
                    if count>=3:
                        print("Our replacement timestamps should be:")
                        print(our_fil_name, names_in_folder)
                        zipped_ = list(zip(names_in_folder,tstamps_in_folder))
                        sorted_zipped = sorted(zipped_, key=lambda x: x[0])
                        index = next(i for i, v in enumerate(sorted_zipped) if v[0] == our_fil_name)
                        ordered = sorted(timestamps)
                        print(ordered)
                        print(sorted_zipped)
                        print("The timestamp we should use is:" +str(ordered[index]))
                        # Write output line to file here!
                        with open("4tstamps.txt", 'a') as out_file:
                            out_file.write("{0:.15f}\n".format(ordered[index]))  # Using .format() to write with 15 decimal places
                            
if __name__ == "__main__":
    main()

