#!/usr/bin/env bash
#################################################################################
## SCRIPT TO INSTALL CCS
##
## Written by Xindi Wang.
## Email: sandywang.rest@gmail.com
## 
#################################################################################
set -e

RC_FILE=$HOME/.bashrc
if [[ ! -e $RC_FILE ]]
then
    RC_FILE=$HOME/.bash_profile
fi
INSTALL_PATH=$( dirname $0 )
if [[ ! -n $FSLDIR || ! -e $FSLDIR ]]
then
    echo "Please install FSL first!"
    exit 1
fi

if [[ ! -n $FREESURFER_HOME || ! -e $FREESURFER_HOME ]]
then
    echo "Please install FreeSurfer first!"
    exit 1
fi

if [[ ! -n $CCSDIR || ! -e $CCSDIR ]]
then
    read -p "Enter the path where you want to install CCS: " CCSPARENT
    CCSDIR=$CCSPARENT/ccs
    mkdir -p $CCSDIR
    if [[ $? -eq 0 ]]
    then
        echo "CCSDIR=$CCSDIR" >> $RC_FILE
        echo "export CCSDIR" >> $RC_FILE
        echo "" >> $RC_FILE
    else
        exit 1
    fi
    
    cp -rv $INSTALL_PATH/../gui $CCSDIR
    if [[ $? -eq 0 ]]
    then
        echo PYTHONPATH='$PYTHONPATH':'$CCSDIR'/gui >> $RC_FILE
        echo "export PYTHONPATH" >> $RC_FILE
        echo "" >> $RC_FILE
    else
        echo "Copy gui directory Failed!" >&2
        exit 1
    fi

    cp -rv $INSTALL_PATH/bin $CCSDIR
    if [[ $? -eq 0 ]]
    then
        echo PATH='$PATH':'$CCSDIR'/bin >> $RC_FILE
        echo "export PATH" >> $RC_FILE
        echo "" >> $RC_FILE
    else
        echo "Copy bin directory Failed!" >&2
        exit 1
    fi

    if [[ $? -eq 0 ]]
    then
        chmod 755 -Rv $CCSDIR
        chgrp $GROUPS -Rv $CCSDIR
        chown $USER -Rv $CCSDIR
    else
        exit 1
    fi
fi

if [[ ! -n $CCS_MAX_QUEUE ]]
then
    read -p "Enter the number of max queue for CCS pipeline: " CCS_MAX_QUEUE
    if [[ $? -eq 0 ]]
    then
        echo "CCS_MAX_QUEUE=$CCS_MAX_QUEUE" >> $RC_FILE
        echo "export CCS_MAX_QUEUE" >> $RC_FILE
        echo "" >> $RC_FILE
    else
        exit 1
    fi
fi

if [[ ! -n $MATLAB_HOME || ! -e $MATLAB_HOME ]]
then
    read -p "Enter the root path of MATLAB: " MATLAB_HOME
    echo "MATLAB_HOME=$MATLAB_HOME" >> $RC_FILE
    echo "export MATLAB_HOME" >> $RC_FILE
    echo "" >> $RC_FILE
fi

source $RC_FILE
