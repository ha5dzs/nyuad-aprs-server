#!/bin/sh
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "$0 [config file]"
    exit
fi

CONFIGFILE=$1

# This variable is used in the Python script being called.
export INSTALLROOT=/opt/trackdirect


if ps -eo pid,pgid,cmd | grep -v grep | grep "bin/wsserver.py --config $CONFIGFILE" ; then
    exit 0
else
    # In our system, no other custom libraries are loaded.
    export PYTHONPATH=$INSTALLROOT/server

    python $INSTALLROOT/server/bin/wsserver.py --config $CONFIGFILE
    exit 0
fi