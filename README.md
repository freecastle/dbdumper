This script is intendend to simplify the backup process of MySQL and PostgreSQL databases. It dumps all or a list of databases of a given host and prints it to STDOUT or to files, both optionally compressed with bzip2.



Installation
============

All you need is to download (or copy paste) the script to your system and make it executable.

Download to current directory
-----------------------------

1.  Download with
	* curl

			curl -O https://raw.github.com/freecastle/dbdumper/master/dbdumper.sh

	* wget

			wget https://raw.github.com/freecastle/dbdumper/master/dbdumper.sh

2.  Setting execution permissions

		chmod +x dbdumper.sh

Download to another path
------------------------

1.  Download to ```/usr/local/bin``` with
	* curl

			curl -o /usr/local/bin/dbdumper.sh https://raw.github.com/freecastle/dbdumper/master/dbdumper.sh

	* wget

			wget -O /usr/local/bin/dbdumper.sh https://raw.github.com/freecastle/dbdumper/master/dbdumper.sh

2.  Setting execution permissions

		chmod +x /usr/local/bin/dbdumper.sh



Options
=======

*   ```-b``` compress the output with bzip2
*   ```-d``` space separated list of database name(s) (defaults to all databases, wildcards allowed)
*   ```-D``` space separated list of database name(s) to ignore (wildcards allowed)
*   ```-f``` adds timestamp to the filename
*   ```-H``` database host (defaults to "localhost")
*   ```-p``` save path of the dumps; if not set, dumps will be pushed to STDOUT
*   ```-t``` not yet implemented: space separated list of table name(s) (defaults to all tables, wildcards allowed)
*   ```-T``` not yet implemented: space separated list of table name(s) to ignore (wildcards allowed)
*   ```-u``` user name (defaults to the user name running the script)
*   ```-v``` database vendor (either "mysql" or "pgsql", defaults to "mysql")
*   ```-V``` dry-run, commands are not going to be executed but printed
*   ```-h``` this help message



Examples
========

	dbdumper.sh -v pgsql -p /tmp/backup

Dumps all databases of a PostgreSQL instance on ```localhost``` to ```/tmp/backup```. The files will be named like ```dbname.pg.sql```.


	dbdumper.sh -d 'dbname1 dbname2' -p /tmp/backup -f -b

Dumps the localhosts MySQL databases ```dbname1``` and ```dbname2``` to ```/tmp/backup```. The dumps will be bzip2ed and named with a timestamp, for example ```dbname1_20130528_150000.my.sql.bz2``` and ```dbname2_20130528_150000.my.sql.bz2```.


	dbdumper.sh -H mysql.example.com -u backupuser -D 'dbname1 *_tmp' > /tmp/backup/dbdump.sql

This will connect to the MySQL server ```mysql.example.com``` with the user name ```backupuser``` (password has either to be typed in or use ```~/.my.cnf``` of ```~/.pgpass``` for PostgreSQL). It will fetch all databases except for the one named ```dbname1``` and the ones that match the pattern ```*_tmp```. The output will be redirected to the file ```/tmp/backup/dbdump.sql```.
