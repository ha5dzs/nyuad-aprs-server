In `collector.py`, lines 9-19, the path to the config file is hard-coded. Perhaps modify this for an absolute path.

In `remover.py`, lines 15-25, the same thing happens.

In `stationremover.py`, lines 14-24, ditto :)

In `wsserver.py`, similar shenanigans are happening, but it relies on `TrackDirectConfig()`.