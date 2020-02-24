#!/bin/bash

rm -rf /var/www/html
ls -trla /var/www/html
echo "Contents of /var/www"
ls -trla /var/www

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

        rm  -rf /var/www/html/wp-content/uploads
	if [[ -d /uploads ]]; then
		ln -s /uploads /var/www/html/wp-content/uploads
	else
		ln -s /wordpress/wp-content/uploads /var/www/html/wp-content/uploads
	fi
else
    echo "Polyscripted mode is off. To enable it, either:"
    echo "  1. Set the environment variable: MODE=polyscripted"
    echo "  2. OR create a file at path: /polyscripted"

    # Symlink the mount so it's editable
    ln -s /wordpress /var/www/html
fi

