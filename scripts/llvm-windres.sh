#!/usr/bin/bash

set -e

rc_options=$*

if [ ! -t 0 ] 
then 
    cat > rc-file.rc
    $TARGET-windres $rc_options rc-file.rc
else 
    $TARGET-windres $rc_options
fi