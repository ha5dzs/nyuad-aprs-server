#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "$0 [config file path]"
    exit
fi

CONFIGFILE=$1

# This variable is used in the Python script being called.
export INSTALLROOT=/opt/trackdirect

if ps -ef | grep -v grep | grep "bin/remover.py $CONFIGFILE" ; then
    exit 0
else
    # In our system, no other custom libraries are loaded.
    export PYTHONPATH=$INSTALLROOT/server

    #Delete the collector logfiles
    rm -f $INSTALLROOT/server/log/*.log.*

    python $INSTALLROOT/server/bin/remover.py $CONFIGFILE

    exit 0
fi
