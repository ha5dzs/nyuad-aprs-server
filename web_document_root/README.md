It seems that the PHP stuff is setting the ROOT variable to this directory, as per `bootstrap.php`.

In `common.php`, line 1759, it seems to go ABOVE the root directory, to get the config file. It seems to load the websocket-specific stuff. Furhter, in line 1812, it loads the config file again, for the 'Website' section.
In `pdoconnection.php`, line 12, the config file is being read in again, and the database user is set with 'get_current_user()', which returns the owner of the PHP file.

So, probably these two sections would need a symlink or something