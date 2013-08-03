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

# Create UDF Options

## Hostname Option
#<udf name="PINCH_HOSTNAME" label="Your server hostname"
#    default="chewfargen.yourdomain.com"
#    example="hillbilly.yourdomain.com">

## Timezone Option
#<udf name="PINCH_TIMEZONE" label="Your server timezone"
#    default="Australia/NSW"
#    example="America/Chicago">

## Custom SSH Option
#<udf name="PINCH_SSH_PORT" label="Set your SSH port"
#    default="3636"
#    example="4914">

## New Root User
#<udf name="PINCH_ROOT_USER" label="Enter the username of the new root user"
#    default="sudoninja"
#    example="wackytubeman">

## New Root User Password
#<udf name="PINCH_ROOT_USER_PASSWORD" label="Enter the password of the new root user (superuser)">

## MariaDB Root Password
#<udf name="PINCH_MARIADB_PASSWORD" label="Enter the root password for your MariaDB server">

(

# Retrieve Pinch Library
source <ssinclude StackScriptID="6088">

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