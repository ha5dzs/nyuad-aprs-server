#!/bin/sh

echo "Starting scripts:"
echo "Collector 1:"
/opt/trackdirect/server/scripts/collector.sh trackdirect.ini 0 &
echo "Collector 2:"
/opt/trackdirect/server/scripts/collector.sh trackdirect.ini 1 &
echo "Websocket server"
/opt/trackdirect/server/scripts/wsserver.sh trackdirect.ini &

exit 0