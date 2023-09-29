__version__ = "1.1"
__author__ = "Per Qvarforth, Zoltan Derzsi"

# Old school way of doing it.
from trackdirect.TrackDirectDataCollector import *
from trackdirect.TrackDirectWebsocketServer import *
from trackdirect.TrackDirectConfig import *


# In this new Python installation, something weird is going on with how modules are being imported.
#import trackdirect.TrackDirectDataCollector
#import trackdirect.TrackDirectWebsocketServer
#import trackdirect.TrackDirectConfig
