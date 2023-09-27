This is the Python library, where all the magic happens.

The scripts that call the corresponding stuff in `../bin/*` rely on this code. Previously, I had issues loading this into a Python environment, I kept getting empty objects.
In the `populate()` method of the `TrackDirectConfig` class, the path for `configFile` is hard-coded to the user's directory.