#! /usr/local/bin/tcsh -f

#  Licensing
#source /tools/commercial/flexlm/flexlm.cshrc
#
#setenv LORENTZ_LICENSE_FILE 27017@sunv20z-1.eecs.berkeley.edu
#setenv RLM_LICENSE 5053@sunv40z-1.eecs.berkeley.edu

# Cadence Settings
#setenv SPECTRE_DEFAULTS -E
#setenv CDS_Netlisting_Mode "Analog"
#setenv CDS_AUTO_64BIT ALL


# Setup Additional Tools
#setenv SPECTRE      /tools/cadence/SPECTRE/SPECTRE191
#setenv MMSIM_HOME   /tools/cadence/MMSIM/MMSIM151
#setenv CDS_INST_DIR /tools/cadence/IC/IC617
#setenv CDSHOME      $CDS_INST_DIR


#set path = ( ${SPECTRE}/bin \
#    ${MMSIM_HOME}/tools/bin \
#    ${CDS_INST_DIR}/tools/bin \
#    ${CDS_INST_DIR}/tools/dfII/bin \
#    ${CDS_INST_DIR}/tools/plot/bin \
#    $path \
#    )
setenv TSMC_CAL_DFM_PATH /TECH/tsmc/28HPCPLUS/TECH_LIB/PDK/current/Calibre/rcx/DFM
set path = ( $TSMC_CAL_DFM_PATH $path)
### Setup BAG
source .cshrc_bag
