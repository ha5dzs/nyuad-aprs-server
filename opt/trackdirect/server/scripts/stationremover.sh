#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "$0 [config file path] [station id]"
    exit
fi

CONFIGFILE=$1
STATIONID=$2

# This variable is used in the Python script being called.
export INSTALLROOT=/opt/trackdirect

if ps -ef | grep -v grep | grep "bin/stationremover.py $CONFIGFILE $STATIONID" ; then
    exit 0
else
    CURRENTDIR=$(dirname $0)

    # In our system, no other custom libraries are loaded.
    export PYTHONPATH=$INSTALLROOT/server

    python $INSTALLROOT/server/bin/stationremover.py $CONFIGFILE $STATIONID
    exit 0
fi
