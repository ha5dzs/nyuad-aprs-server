It seems that the PHP stuff is setting the ROOT variable to this directory, as per `bootstrap.php`.

`[solved]` In `common.php`, line 1759, it seems to go ABOVE the root directory, to get the config file. It seems to load the websocket-specific stuff. Furhter, in line 1812, it loads the config file again, for the 'Website' section.
`[solved]` In `pdoconnection.php`, line 12, the config file is being read in again, and the database user is set with 'get_current_user()', which returns the owner of the PHP file.

Solution:

```php
define('ROOT', dirname(dirname(__FILE__))); // this was in bootstrap.php
parse_ini_file(ROOT . '/trackdirect.ini', true); // the offending item described above.
```

`[TODO]:` All these  add a symlink to ROOT that points to the config file.
