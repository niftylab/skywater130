export TECH_DIR="skywater130"
export ROOT_DIR="${TECH_DIR}/workspace_setup"

# files to copy from workspace_setup
cp_files=()
# files to link from workspace_setup
ln_files=( ".maginit"
           ".bashrc"
           ".bashrc_bag"
           ".gitignore"
           "lvs_runset.tcl"
           "laygo2_example" )

# user configuration files; copy
for f in "${cp_files[@]}"; do
    cp ${ROOT_DIR}/${f} .
#    git add -f ${f}
done

# standard configuration files; symlink
for f in "${ln_files[@]}"; do
    ln -s ${ROOT_DIR}/${f} .
#    git add -f ${f}
done

# setup .ipython
export CUR_DIR=".ipython/profile_default"
mkdir -p ${CUR_DIR}
ln -s "../../${ROOT_DIR}/ipython_config.py" "${CUR_DIR}/ipython_config.py"
# git add -f ${CUR_DIR}/ipython_config.py

source ${ROOT_DIR}/mag_set_path.sh