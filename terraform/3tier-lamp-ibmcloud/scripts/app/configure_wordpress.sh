#!/bin/bash -xe
wordpress_salt=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
wget https://downloads.wordpress.org/plugin/hyperdb.zip
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
unzip hyperdb.zip
# cp ./hyperdb/db.php /var/www/wordpress/wp-content/
#
cat << EOF > /var/www/wordpress/wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '$DB_NAME' );

/** MySQL database username */
define( 'DB_USER', '$DB_USER' );

/** MySQL database password */
define( 'DB_PASSWORD', '$DB_PASSWORD' );

/** MySQL hostname */
define( 'DB_HOST', '$DB_HOST:3306' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
/* Override WP Admin console settings for Site and Home URLs */
define( 'WP_SITEURL', 'http://$LB_HOSTNAME' );
define( 'WP_HOME', 'http://$LB_HOSTNAME' );
/** MySQL slave hostname */
define( 'SLAVE_DB_HOST', '$SLAVE_DB_HOST:3306' );
/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
$wordpress_salt
/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
/** Debug */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
EOF


cat << EOF > /var/www/wordpress/db-config.php
<?php

\$wpdb->save_queries = false;

\$wpdb->persistent = false;
\$wpdb->check_tcp_responsiveness = true;
\$wpdb->add_database(array(
        'host'     => DB_HOST,     // If port is other than 3306, use host:port.
        'user'     => DB_USER,
        'password' => DB_PASSWORD,
        'name'     => DB_NAME,
));

/**
 * This adds the same server again, only this time it is configured as a slave.
 * The last three parameters are set to the defaults but are shown for clarity.
 */
\$wpdb->add_database(array(
        'host'     => SLAVE_DB_HOST,     // If port is other than 3306, use host:port.
        'user'     => DB_USER,
        'password' => DB_PASSWORD,
        'name'     => DB_NAME,
        'write'    => 0,
        'read'     => 1,
        'dataset'  => 'global',
        'timeout'  => 0.2,
));
EOF
systemctl start php7.2-fpm
systemctl start nginx
if [[ -n $APP_NAME ]]; then
  sleep 5
  wp core install --title="$APP_NAME" --admin_user="$APP_USER" --admin_password="$APP_PASSWORD" --admin_email="$APP_EMAIL" --allow-root --path=/var/www/wordpress --url=http://$LB_HOSTNAME
  sleep 60
fi
