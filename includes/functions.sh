#!/bin/bash -e

#
# Pinch Functions
# Global Functions for Pinch
#
# @package Pinch 2.0
# @since Pinch 1.0
# @author Drew Morris
# @license http://opensource.org/licenses/MIT
#

# Messenger Function
function messenger() {
	echo -e "\e[00;32m\n**** ${1} ****\n \e[00m"   
}

# URL Wrapper
function pinch_url_exists() {
	wget $1
	if [ $? -eq 0 ]
		then messenger "Succesfully Downloaded... Continuing..."
		else messenger "Download failed, aborting!" && sleep 2 && exit
	fi
}

# Check for Existing Components
function pinch_check() {

	# Check pinch Compatability
	messenger "Checking pinch compatability..."

		OS=$(cat /etc/redhat-release | awk {'print $1}')
		if [[ "$OS" -ne "CentOS" ]]; then
			messenger "Please run this script on CentOS. Exiting..."
			exit
		fi

	# Check for Root Privledges
	messenger "Checking privledges..."

		if [[ $(/usr/bin/id -u) -ne 0 ]]; then
			messenger "Please run this script as root or using sudo. Exiting..."
			exit
		fi

	# Check existing installations
	messenger "Checking existing installations..."

		# Check 1: PID's
		if [[ -e "/var/run/nginx.pid" || -e "/var/run/php-fpm.pid" || -e "/var/run/mysql.pid" ]];

			then PARAM_CHECK="Error: PID running under Nginx, PHP-FPM or MySQL / MariaDB"
		
		# Check 2: Existing Installation Directories
		elif [[ -d ${PARAM_NGINX_PREFIX} || -d ${PARAM_PHP_PREFIX} || -d ${PARAM_MARIADB_PREFIX} ]];

			then PARAM_CHECK+="Error: Conflicting Installation Directories of Nginx, PHP-FPM or MySQL / MariaDB Found"

		else

			PARAM_CHECK="0"
			
		fi

		if [[ ${PARAM_CHECK} == "0" ]];
			then messenger "No existing installations found... Continuing..."
			else messenger "${PARAM_CHECK}" && exit
		fi

}
