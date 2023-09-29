#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "$0 [config file] [collector number]"
    exit
fi

CONFIGFILE=$1
COLLECTORNUMBER=$2

# This variable is used in the Python script being called.
export INSTALLROOT=/opt/trackdirect


if ps -ef | grep -v grep | grep "bin/collector.py $CONFIGFILE $COLLECTORNUMBER" ; then
    exit 0
else
    # In our system, no other custom libraries are loaded.
    export PYTHONPATH=$INSTALLROOT/server

    python $INSTALLROOT/server/bin/collector.py $CONFIGFILE $COLLECTORNUMBER
    exit 0
fi
