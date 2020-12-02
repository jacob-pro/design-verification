cd ./src
module use /eda/cadence/modules
module load course/COMS30026
irun calc1_sn_env.e calc1_sn.v -gui -access rw -coverage all -covtest my_code_coverage_results -snprerun "config cover -write_model=ucm" -nosncomp &
