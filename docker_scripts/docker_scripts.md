# Docker scripts

## Nanopore guppy basecalling
`run_guppy_basecaller_v6_gpu_docker.sh` - script to run guppy basecalling using gpu

Note:
* use public docker image for machines other than the in-house gpu machine
* instead of the hardcoded guppy config (-c) possibly specify flowcells and kits (see `guppy_basecaller --print_workflows`)
* potentially optimize calllers and other parameters (e.g. `--num_callers, --cpu_threads_per_caller, --gpu_runners_per_device`)


  