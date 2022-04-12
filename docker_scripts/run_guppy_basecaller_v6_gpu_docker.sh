#!/bin/bash
### Script details ###
# script_name: run_guppy_basecaller_v6_gpu_docker.sh
# script_description: run nanopore guppy basecaller using docker and gpu
# author: Peter Repiscak
# email: peter.repiscak@ccri.at
# usage: bash run_guppy_basecaller_v6_gpu_docker.sh <run_name> <path-to-flongle-data> <accuracy_mode> > guppy_basecaller_flongleX_${CURRENT_DATE}.log
# bash run_guppy_basecaller_v6_gpu_docker.sh flongle21 /raid/nanopanel2/datasets/Flongle21/no_sample/20211214_1155_MN28473_AHX785_5b885336 hac > guppy_basecaller_hac_flongle21_${CURRENT_DATE}.log
##########################

# useful links and commands:
#  https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html
# export NVIDIA_VISIBLE_DEVICES=1  - to limit to specific device 
# --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all 
# docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda:9.0-base nvidia-smi
# docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all core_bioinf/guppy:3.6.1 guppy_basecaller

# TO-DO
# [ ] - add checks for input parameters
# [ ] - add tests/checks for mode and other!

# INPUT DATA INFO
DATA_NAME=$1 # e.g. "flongle1"
DATA_DIR=$2  # nanopore directory
MODE=$3      # fast, hac (default), sup

# input dir that contains fast5 or fast5_pass dir
# INPUT_DIR=<dir>
# Assuming fast5_dir or fast5_pass located in the $(pwd) dir

# guppy_basecaller arguments:
#  -i input dir (that contains fast5)
#  -s output_dir
#  -c config
# ! instead of config may want to specify chemistry and kit

# https://community.nanoporetech.com/protocols/Guppy-protocol/v/gpb_2003_v1_revt_14dec2018/setting-up-a-run-configurations-and-parameters
#  --device, -x auto - Use the first GPU in the system, no memory limit
# -x cuda:all:100% - Use all GPUs in the system, no memory limit
gpu_visible=all # 0,1,2,3,all(0-3) # devices visible to docker
gpu_to_use=auto #"cuda:0:100%"  #"cuda:all:100%" ; "cuda:0,1,2:100%" ; "cuda:0,1:100%"
# --devices how many of the visible onse to use
# callers*cpu_threads_per_caller; e.g. 8*5 = 40 threads threads; 8*5

echo "DATA_NAME: ${DATA_NAME}"
echo "DATA_DIR: ${DATA_DIR}"
echo "MODE: ${MODE}"
# add check if fast5 files are present
# echo "Fast5 located in ${FAST5_DIR}"

# checking if fast5_pass exists - if yes use it else use fast5
fast5_dir="./fast5"
if [ -d "${DATA_DIR}/fast5_pass" ]; then
	fast5_dir="./fast5_pass"
fi

echo "fast5 dir used in docker: ${fast5_dir}"

docker_image="core_bioinf/guppy:6.0.1"  
#docker_image="genomicpariscentre/guppy-gpu:6.0.1"  # public docker image
docker_run="nvidia-docker run --rm --user $(id -u):$(id -g) -e NVIDIA_VISIBLE_DEVICES=${gpu_visible} --volume=${DATA_DIR}:/workspace ${docker_image}"
echo "Running command: ${docker_run} guppy_basecaller \
        -i ${fast5_dir} \
        -s ./${DATA_NAME}_guppy_v6_output_${MODE} \
        -c dna_r9.4.1_450bps_${MODE}.cfg \
        --fast5_out \
        --trace_categories_logs Move \
        --num_callers 8 \
        --cpu_threads_per_caller 5 \
        --gpu_runners_per_device 8 \
        --chunks_per_runner 768 \
        --chunk_size 500 \
        --disable_pings \
        --compress_fastq \
        --device ${gpu_to_use}"

${docker_run} guppy_basecaller \
	-i ${fast5_dir} \
	-s ./${DATA_NAME}_guppy_v6_output_${MODE} \
	-c dna_r9.4.1_450bps_${MODE}.cfg \
	--fast5_out \
	--trace_categories_logs Move \
	--num_callers 8 \
	--cpu_threads_per_caller 5 \
	--gpu_runners_per_device 8 \
	--chunks_per_runner 768 \
	--chunk_size 500 \
	--disable_pings \
	--compress_fastq \
	--device ${gpu_to_use}
