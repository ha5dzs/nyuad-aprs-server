# NYUAD's APRS server front-end implementation

This is based on TrackDirect, but I implemented some modifications to fit our requirements. It is listening on the APRS and the CWOP network. I am writing this documentation as I am going through the code, so there will undoubtedly be some factual errors. I will correct them as I go.

## How does it work?

Most of the work is done with Python scripts, and are working from the included *trackdirect* **module**.

The core traffic is being accessed by instances of the data **collector** script, and the incoming packets are processed. These scripts upload the processed packets to an sql **database**. The system's web server fetches the required data from the database using **php** scripts, and it gets displayed in the browser using a bunch of javascript libraries.

Telemetry doesn't seem to work, will need to look into it.

### Environment variables

A lof of stuff seems to be hard-coded. I made the environment variable `INSTALLROOT` and set it to `/opt/trackdirect`. I needed to update all relevant scripts everywhere. I use this to navigate with respect to the installation directory. This way, I no longer need to run it as a standard user.

I overwrite `PYTHONPATH` so I can load the trackdirect module. I do not append to it. Keep this in mind if you are using some custom Python stuff.

#### TCP ports used

* 80 for the website
* 14580 for APRS
* one for the CWOP server, as configured
* 5432 for the database access, local to the machine
* 9000 for websocket comms (local to the machine, the JavaScript stuff accesses the database real-time this way, if I understand this correctly)

If some IT department is setting up the firewall, tell them that they need to enable the 'unknown application' option, otherwise random packet losses will occur.

### Prerequisites

My server is running Ubuntu 22.04, so you may need to adapt this.

Install some required ubuntu packages

```shell
sudo apt-get update
sudo apt-get install libpq-dev postgresql postgresql-client-common postgresql-client libevent-dev apache2 php libapache2-mod-php php-dom php-pgsql libmagickwand-dev imagemagick php-imagick inkscape php-gd libjpeg-dev python3 python3-dev python3-pip python-is-python3
```

### Map tile API key

For low-volume applications, OpenStreetMap's tile servers MAY be OK, but you should get alternative solutions. You may want to run your own tile server, or get an API key from a different service. If you make any changes to this, then

```shell
sudo /opt/trackdirect/jslib/build.sh
```

### Connection to the packet network

As the collector scripts are syphoning out each and every packet ever being transmitted, this is going to be a considerable load on someone's server. NYUAD has its own aprs server set up, so we will connect to this one:

* APRS: [http://aprs.abudhabi.nyu.edu:14501](http://aprs.abudhabi.nyu.edu:14501)
* CWOP: [http://aprs.abudhabi.nyu.edu:14502](http://aprs.abudhabi.nyu.edu:14502)

You should connect to these servers from within NYUAD's internal network. There is enough bandwidth there, hammer away all you like.

### Installation

After cloning, you'll need to do some manual copying, because nothing is in a package.

But first, install the needed python libraries

```shell
pip install -r requirements.txt
```

#### Database

Set up the database (connect to database using: `sudo -u postgres psql`). If you choose to replace "database_user" and "database_password", then update `trackdirect.ini` as well.

**Note** that some server scripts have this username and password saved as well, edit them if you change this

```shell
sudo -u postgres psql
```

...once you are in, then:

```sql
CREATE DATABASE trackdirect ENCODING 'UTF8';

CREATE USER database_user WITH PASSWORD 'database_password';
ALTER ROLE database_user WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "trackdirect" to database_user;
```

**This is not secure at all!** Normally, for any exposed environment, publishing any superuser details is something extremely idiotic. But in this case:

* The sql system is not used by anything else, and the port is not accessible outside
* It doesn't store any sensitive information, only sorted packets, which are unencrypted and publicly available anyway
* Since the database is filled through the python script, the PHP script only makes queries, so it would be very difficult to hack into it from outside
* Old data is getting purged regularly

It might be a good idea to play around with some Postgresql settings to improve performance (for this application, speed is more important than minimizing the risk of data loss). For Ubuntu 22.04, posgresql version 14 is bundled, your system might be different.

Some settings in `/etc/postgresql/14/main/postgresql.conf` that might improve performance:

```ini
shared_buffers = 2048MB              # I recommend 25% of total RAM
synchronous_commit=off               # Avoid writing to disk for every commit
commit_delay=100000                  # Will result in a 0.1s commit delay
```

Restart postgresql

```shell
sudo systemctl restart postgresql
```

##### Set up database tables

The script has the database user and password saved, you can execute it as a standard user. It populates the database with the bundled `.sql` files, so other things can interact with them.

```shell
/opt/trackdirect/server/scripts/db_setup.sh trackdirect 5432 /opt/trackdirect/misc/database/tables
```

#### Configure trackdirect

Before starting the websocket server you need to update the trackdirect configuration file (`trackdirect/config/trackdirect.ini`).

**PLEASE READ THIS FILE, UNDERSTAND IT, and CHANGE THE STATION CALLSIGNS!**

```shell
nano /opt/trackdirect/config/trackdirect.ini
```

#### Start the collectors

**Do not start the collector script until the .ini file is set up properly!**

Start the collector by using the provided shell-script. Note that if you have configured multiple collectors (fetching from multiple aprs servers, for example both APRS-IS and CWOP-IS) you need to call the shell-script multiple times. The script should be executed by the user that you granted access to the database "trackdirect".

```shell
/opt/trackdirect/server/scripts/collector.sh trackdirect.ini 0

/opt/trackdirect/server/scripts/collector.sh trackdirect.ini 1
```

The third argument is the collector number: in `trackdirect.ini`, you need to set up `[collector0]` and `[collector1]` for this to work. **Change the callsign and passcode accordingly!**

#### Start the websocket server

When the user interacts with the map we want it to be populated with objects from the backend. To achive good performance we avoid using background HTTP requests (also called AJAX requests), instead we use websocket communication. The included trackdirect js library (trackdirect.min.js) will connect to our websocket server and request objects for the current map view.

Start the websocket server by using the provided shell script, the script should be executed by the user that you granted access to the database "trackdirect".

```shell
/opt/trackdirect/server/scripts/wsserver.sh trackdirect.ini
```


#### Trackdirect js library

All the map view magic is handled by the trackdirect js library, it contains functionality for rendering the map (using Google Maps API or Leaflet), functionality used to communicate with backend websocket server and much more.

If you do changes in the js library (jslib directory) you need to execute build.sh to deploy the changes to the htdocs directory.

```shell
/opt/trackdirect/jslib/build.sh
```

#### Set up webserver

Webserver should already be up and running (if you installed all specified ubuntu packages).

Add the following to /etc/apache2/sites-enabled/000-default.conf. You need to replace "my_username".

```html
<Directory "/var/www/html">
    Options FollowSymlinks
    AllowOverride All
    Require all granted
</Directory>
```

Enable rewrite and restart apache

```shell
sudo a2enmod rewrite
sudo systemctl restart apache2
```

For the symbols and heatmap caches to work we need to make sure the webserver has write access (the following permission may be a little bit too generous...)

```shell
chmod 777 /var/www/html/public/symbols
chmod 777 /var/www/html/public/heatmaps
```

## Deployment

* Set up aprsc to hammer on it locally
* Set up firewall and port forwarding
* Check user names and passwords for the database
* Check if `trackdirect.ini` is free from typos
* Check if scripts are running without failure (collectors connecting, websocket server not crashing, etc.)
* Verify that files to be moved have been moved to the correct place and set permissions accordingly
* `trackdirect_backend.service` systemd service unit files to be copied to `/etc/systemd/system`
  * `sudo systemctl enable trackdirect_backend`
  * `sudo systemctl start trackdirect_backend`
* Set up cronjob for cleaning, see below

### Cleanup schedule

If you do not have infinite storage we recommend that you delete old packets, schedule the remover.sh script to be executed about once every hour. And again, if you are using OGN as data source you need to run the ogn_devices_install.sh script at least once every hour.

Note that the collector and wsserver shell scripts can be scheduled to start once every minute (nothing will happen if it is already running). I even recommend doing this as the collector and websocket server are built to shut down if something serious goes wrong (eg lost connection to database).

Crontab example (crontab for the user that owns the "trackdirect" database)

```cron
40 * * * * /opt/trackdirect/server/scripts/remover.sh trackdirect.ini 2>&1 &
0 * * * * /opt/trackdirect/server/scripts/ogn_devices_install.sh trackdirect 5432 2>&1 &
* * * * * /opt/trackdirect/server/scripts/wsserver.sh trackdirect.ini 2>&1 &
* * * * * /opt/trackdirect/server/scripts/collector.sh trackdirect.ini 0 2>&1 &
```

### Server Requirements

How powerful server you need depends on what type of data source you are going to use. If you, for example, receive data from the APRS-IS network, you will probably need at least a server with 4 CPUs and 8 GB of RAM, but I recommend using a server with 8 CPUs and 16 GB of RAM.


## Disclaimer

These software tools are provided "as is" and "with all its faults". We do not make any commitments or guarantees of any kind regarding security, suitability, errors or other harmful components of this source code. You are solely responsible for ensuring that data collected and published using these tools complies with all data protection regulations. You are also solely responsible for the protection of your equipment and the backup of your data, and we will not be liable for any damages that you may suffer in connection with the use, modification or distribution of these software tools.
