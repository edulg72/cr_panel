#!/bin/bash

USER='golnovus'
PASS='xfn0t36c'

cd $OPENSHIFT_HOMEDIR/app-root/repo/scripts/

case $((10#$(date +%H) % 2)) in
  0) 
     ./scan_UR.sh $USER $PASS >> ${OPENSHIFT_LOG_DIR}/scan_UR.log
    ;;
  1)
     ./scan_PU.sh $USER $PASS >> ${OPENSHIFT_LOG_DIR}/scan_PU.log
    ;;
esac


