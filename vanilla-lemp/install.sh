#!/bin/bash -x

#
# drewsymo/Pinch
# Generic Controller for Pinch installer
#
# Installs a LEMP stack and sets up system for server production-environment.
#
# @package Pinch 2.1
# @since Pinch 1.0
# @author Drew Morris
# @author Vincent van daal
#

# Create Global Options

## Hostname Option
read -e -p "Enter the hostname: " -i "replace_me.with_your_host.com" PINCH_HOSTNAME

## Timezone Option
read -e -p "Enter the timezone: " -i "Australia/NSW" PINCH_TIMEZONE

## Custom SSH Port
read -e -p "Enter the custom SSH port: " -i "3636" PINCH_SSH_PORT

## New Root User
read -e -p "Enter the sudo user: " -i "sudoninja" PINCH_ROOT_USER

## Root User Password
read -e -p "Enter the sudo user password: " -i "sudoninjapassword" PINCH_ROOT_USER_PASSWORD

## MariaDB Root Password
read -e -p "Enter the MariaDB root password: " -i "mariadbpassword" PINCH_MARIADB_PASSWORD

(

# Retrieve Pinch Library
. pinch_library.sh

# Run Pinch Installer
pinch=(
	'pinch_essentials'
	'pinch_rpm'
	'pinch_nginx'
	'pinch_php'
	'pinch_varnish'
	'pinch_mariadb'
	'pinch_security'
	'pinch_configure_lemp'
	'pinch_engage'
)

for i in "${pinch[@]}"
do
	echo -e '\E[37;44m'"\033[1m [$i] Running $i \033[0m"
	$i
	wait
done

) 2>&1 | tee /var/log/stackscript.log