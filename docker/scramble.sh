#!/bin/bash

if [[ -d /var/www/html ]]; then
	echo "Remvoing /var/www/html to mount it from /wordpress where files are stored"
	rm -rf /var/www/html
fi

if [[ "$MODE" == "polyscripted" || -f /polyscripted ]]; then

	echo "===================== POLYSCRIPTING ENABLED =========================="
	if [ -d /wordpress ]; then
	    echo "Copying /wordpress to /var/www/html to be polyscripted in place..."
	    echo "This will prevent changes from being saved back to /wordpress, but will protect"
	    echo "against code injection attacks..."
		cp -R /wordpress /var/www/html
	fi

	echo "Starting polyscripted WordPress"
	cd $POLYSCRIPT_PATH
	sed -i "/#mod_allow/a \define( 'DISALLOW_FILE_MODS', true );" /var/www/html/wp-config.php
    	./build-scrambled.sh
	if [ -f scrambled.json ] && s_php tok-php-transformer.php -p /var/www/html --replace; then
		echo "Polyscripting enabled."
		echo "done"
	else
		echo "Polyscripting failed."
		cp /usr/local/bin/s_php /usr/local/bin/php
		exit 1
	fi
else
    echo "Polyscripted mode is off. To enable it, either:"
    echo "  1. Set the environment variable: MODE=polyscripted"
    echo "  2. OR create a file at path: /polyscripted"

    # Symlink the mount so it's editable
    ln -s /wordpress /var/www/html
fi

rm  -rf /var/www/html/wp-content/uploads
if [[ ! -d /uploads ]]; then
	mkdir /uploads
fi
ln -s /uploads /var/www/html/wp-content/uploads
