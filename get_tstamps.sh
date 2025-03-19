#!/bin/bash


# Define the path to the singularity image
singularity_cmd="singularity exec -B /beegfs:/beegfs /homes/vishnu/singularity_images/trapum_pulsarx_fold_docker_20220411.sif"

#root_base_dir="/beegfs/DATA/TRAPUM/SCI-20200703-MK-03/20230910-0024"
root_base_dir="/beegfs/DATA/TRAPUM/SCI-20230907-DP-01/"
output_file="subfolder_tstamp_groups.csv"

> "$output_file"
echo "Subfolder Path,Tstamps,Cfbfs" >> "$output_file"

for subfolder in "$root_base_dir"/*/*/; do
    if [[ -d "$subfolder" ]]; then
        echo "Scanning subfolder: $subfolder"
        
        declare -A tstamp_groups

        for beam_folder in "$subfolder"/cfbf*/; do
            if [[ -d "$beam_folder" ]]; then
                beam_id=$(basename "$beam_folder")
                echo "  Processing beam: $beam_id"

                beam_tstamps=()
                skip_beam=false

                # Check if there are any .fil files
                fil_count=$(find "$beam_folder" -name "*.fil" | wc -l)
                for fil_file in "$beam_folder"/*.fil; do
                    if [[ -f "$fil_file" ]]; then
                        filename=$(basename "$fil_file") 
                        tstamp=$(singularity exec -B /beegfs:/beegfs /homes/vishnu/singularity_images/trapum_pulsarx_fold_docker_20220411.sif readfile "$fil_file" | grep "start time" | awk '{ print $5 }')

                        if [[ "$tstamp" == "0.00000000000000" ]]; then
                            echo "    Skipping beam $beam_id (contains a file with tstamp=0.00000000000000)"
                            skip_beam=true
                            break
                        fi

                        if [[ -n "$tstamp" ]]; then
                            beam_tstamps+=("$tstamp")
                        fi
                    fi
                done

                if [[ "$skip_beam" == true || ${#beam_tstamps[@]} -eq 0 ]]; then
                    echo "    Skipping beam $beam_id (no valid timestamps or contains a file with tstamp=0)"
                    continue
                fi
                
                # Sort timestamps for grouping beams
                IFS=$'\n' beam_tstamps_sorted=($(for i in "${beam_tstamps[@]}"; do echo $i; done | sort))
                sorted_tstamp_list="${beam_tstamps_sorted[*]}"
                
                # Group beams by identical timestamp sequences
                tstamp_groups["$sorted_tstamp_list"]+="$beam_id "
            fi
        done

        # Write to the output file
        if [[ ${#tstamp_groups[@]} -gt 0 ]]; then
            echo "  Found ${#tstamp_groups[@]} unique timestamp groups in $subfolder"
            for tstamp_list in "${!tstamp_groups[@]}"; do
                beams="${tstamp_groups[$tstamp_list]}"
                # Format timestamps as a comma-separated string for CSV
                tstamps_str=$(echo "$tstamp_list" | tr '\n' ',' | sed 's/,$//')
                # Format beam IDs as a comma-separated string for CSV
                cfbfs_str=$(echo "$beams" | tr ' ' ',' | sed 's/,$//')
                echo "\"$subfolder\", \"$tstamps_str\", \"$cfbfs_str\"" >> "$output_file"
                echo "  Group with timestamps [$tstamps_str] contains beams: $cfbfs_str"
            done
        else
            echo "  No valid timestamp groups found in $subfolder"
        fi
        
        # Clean up arrays for next subfolder
        echo "  Finished processing subfolder: $subfolder"
        unset tstamp_groups
        declare -A tstamp_groups
    fi
done

echo "Finished processing all subfolders."
echo "Output saved to $output_file"
