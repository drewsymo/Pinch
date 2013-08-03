#!/bin/bash -x

#
# drewsymo/Pinch
# Library for Pinch installer
#
# Do not deploy this script directly.
#
# @package Pinch 2.1
# @since Pinch 1.0
# @author Drew Morris
# @author Vincent van daal
#

# Essentials
function pinch_essentials() {

	# Update System
	yum -y update

	# Remove Postfix and dependencies of installed
	yum -y remove postfix
	
	# Install Essential Tools
	yum -y install vim wget curl sudo jwhois bind-utils mlocate screen git sendmail vixie-cron crontabs  perl-libwww-perl perl-Time-HiRes

	# Set Hostname
	echo "HOSTNAME=${PINCH_HOSTNAME}" >> /etc/sysconfig/network
	hostname ${PINCH_HOSTNAME}

	# Set Timezone
	ln -s /usr/share/zoneinfo/${PINCH_TIMEZONE} /etc/localtime

}

# Install RPM's / Repositories
function pinch_rpm() {

	rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm
	rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

	cat > /etc/yum.repos.d/MariaDB.repo << EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/5.5/centos6-x86
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

	# Update RPMS / Repositories
	yum -y update

}

# Install Nginx Web Server
function pinch_nginx() {
	yum -y --disablerepo=epel install nginx
}

# Install PHP
function pinch_php() {
	yum -y --enablerepo=remi install php php-fpm php-gd php-mysqlnd php-mbstring php-xml php-mcrypt php-pecl-apc php-pdo
}

# Install Varnish Cache
function pinch_varnish() {
	yum -y --disablerepo=epel install varnish
}

# Install MariaDB
function pinch_mariadb() {
	yum -y --disablerepo=epel install MariaDB-server MariaDB-client
}

# Configure Security
function pinch_security() {

	# Create new root user
	adduser ${PINCH_ROOT_USER}
	echo ${PINCH_ROOT_USER_PASSWORD} | passwd ${PINCH_ROOT_USER} --stdin

	# Install CSF (Firewall)
	cd /tmp
	rm -rf csf/ csf.tgz
	wget http://www.configserver.com/free/csf.tgz
	tar -xzf csf.tgz
	rm -f csf.tgz
	cd csf
	sh install.sh
	cd /tmp
	rm -rf csf/
	echo "Testing IP Tables Modules..."
	perl /etc/csf/csftest.pl
	
	# Adds custom values to csf.conf
	#
	# Based on source: csfinstall.inc and csftweaks.inc (centmin-v1.2.3mod) from the CentminMOD project (http://centminmod.com/)
	#
	
	echo "CSF adding varnish port and changing SSH port in csf.conf"
	sed -i 's/20,21,22,25,53,80,110,143,443,465,587,993,995/20,21,'${PINCH_SSH_PORT}',25,53,80,110,143,443,465,587,993,995,8080/g' /etc/csf/csf.conf
	
	sed -i "s/TCP_OUT = \"/TCP_OUT = \"111,2049,1110,/g" /etc/csf/csf.conf
	sed -i "s/UDP_IN = \"/UDP_IN = \"111,2049,1110,/g" /etc/csf/csf.conf
	sed -i "s/UDP_OUT = \"/UDP_OUT = \"111,2049,1110,/g" /etc/csf/csf.conf
	
	echo "Disabling CSF Testing mode (activating firewall)"
	sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
	
	sed -i 's/LF_DSHIELD = "0"/LF_DSHIELD = "86400"/g' /etc/csf/csf.conf
	sed -i 's/LF_SPAMHAUS = "0"/LF_SPAMHAUS = "86400"/g' /etc/csf/csf.conf
	sed -i 's/LF_EXPLOIT = "300"/LF_EXPLOIT = "86400"/g' /etc/csf/csf.conf
	sed -i 's/LF_DIRWATCH = "300"/LF_DIRWATCH = "86400"/g' /etc/csf/csf.conf
	sed -i 's/LF_INTEGRITY = "3600"/LF_INTEGRITY = "0"/g' /etc/csf/csf.conf
	sed -i 's/LF_PARSE = "5"/LF_PARSE = "20"/g' /etc/csf/csf.conf
	sed -i 's/LF_PARSE = "600"/LF_PARSE = "20"/g' /etc/csf/csf.conf
	sed -i 's/PS_LIMIT = "10"/PS_LIMIT = "15"/g' /etc/csf/csf.conf
	sed -i 's/PT_LIMIT = "60"/PT_LIMIT = "0"/g' /etc/csf/csf.conf
	sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "0"/g' /etc/csf/csf.conf
	sed -i 's/PT_USERMEM = "200"/PT_USERMEM = "0"/g' /etc/csf/csf.conf
	sed -i 's/PT_USERTIME = "1800"/PT_USERTIME = "0"/g' /etc/csf/csf.conf
	sed -i 's/PT_LOAD = "30"/PT_LOAD = "600"/g' /etc/csf/csf.conf
	sed -i 's/PT_LOAD_AVG = "5"/PT_LOAD_AVG = "15"/g' /etc/csf/csf.conf
	sed -i 's/PT_LOAD_LEVEL = "6"/PT_LOAD_LEVEL = "8"/g' /etc/csf/csf.conf
	
	sed -i 's/LF_DISTATTACK = "0"/LF_DISTATTACK = "1"/g' /etc/csf/csf.conf
	sed -i 's/LF_DISTFTP = "0"/LF_DISTFTP = "1"/g' /etc/csf/csf.conf
	sed -i 's/LF_DISTFTP_UNIQ = "3"/LF_DISTFTP_UNIQ = "6"/g' /etc/csf/csf.conf
	sed -i 's/LF_DISTFTP_PERM = "3600"/LF_DISTFTP_PERM = "6000"/g' /etc/csf/csf.conf
	
	sed -i 's/DENY_IP_LIMIT = \"100\"/DENY_IP_LIMIT = \"1000\"/' /etc/csf/csf.conf
	sed -i 's/DENY_TEMP_IP_LIMIT = \"100\"/DENY_TEMP_IP_LIMIT = \"1000\"/' /etc/csf/csf.conf
	
	# SSH Configuration

	## Disable UseDNS
	sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config

	## Change Default SSH Port
	if [[ ! -z "${PINCH_SSH_PORT}" ]];
		then
		sed -i 's/#Port 22/Port '"${PINCH_SSH_PORT}"'/g' /etc/ssh/sshd_config
	fi
	
	## Deny / Allow SSH Users
	sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	echo "${PINCH_ROOT_USER} ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "AllowUsers ${PINCH_ROOT_USER}" >> /etc/ssh/sshd_config

	# Networking / Sys Configuration

	## Kernel Hardening
	cp /etc/sysctl.conf /etc/sysctl.conf.bak

	cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_timestamps = 0
EOF

	## Disable IPv6
	echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
	echo "IPV6INIT=no" >> /etc/sysconfig/network

	## Enable SELinux
	sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config

	## Remove unnecessary Users
	REMOVERUSERS=("apache" "games" "gopher" "postfix")
	for DELUSER in "${REMOVERUSERS[@]}"
	do
		userdel ${DELUSER}
	done
}

# Configure LEMP Stack
function pinch_configure_lemp() {

	# Create LEMP user
	useradd -r -s /sbin/nologin www-data

	# Global Settings
	MEMORY=$(free -m | awk '/^Mem:/{print $2}')
	CPU=$(grep -c ^processor /proc/cpuinfo)

	# PHP-FPM
	## Set Permissions
	sed -i 's/;listen.mode = 0666/listen.mode = 0600/g' /etc/php-fpm.d/www.conf

	## Update User
	sed -i 's/;listen.owner = nobody/listen.owner = www-data/g' /etc/php-fpm.d/www.conf
	sed -i 's/;listen.group = nobody/listen.group = www-data/g' /etc/php-fpm.d/www.conf

	sed -i 's/user = apache/user = www-data/g' /etc/php-fpm.d/www.conf
	sed -i 's/group = apache/group = www-data/g' /etc/php-fpm.d/www.conf

	## Set Listening Socket
	sed -i 's@listen = 127.0.0.1:9000@listen = /var/run/php-fpm.sock@g' /etc/php-fpm.d/www.conf

	## Customise PHP.ini
	sed -i 's/disable_functions =/disable_functions = show_source, passthru, exec, popen, proc_open, allow_url_fopen, allow_url_include/g' /etc/php.ini
	sed -i 's@;date.timezone =@date.timezone = ${PINCH_TIMEZONE}@g' /etc/php.ini

	## FastCGI Configuration
	echo "fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;" >> /etc/nginx/fastcgi_params

	# Nginx
	sed -i 's/user  nginx;/user www-data;/g' /etc/nginx/nginx.conf
	sed -i 's/listen       80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

	## Tune Worker Processes & Connections (Not accurate for most para-virtualised systems)
	WP=$((${CPU}*2))
	sed -i 's/worker_processes  1;/worker_processes '${WP}';/g' /etc/nginx/nginx.conf

	WC=$((1024*${CPU}))
	sed -i 's/worker_connections  1024;/worker_connections '${WC}';/g' /etc/nginx/nginx.conf

	# Varnish
	## Customise Configuration
	mv /etc/sysconfig/varnish /etc/sysconfig/varnish.bak

	## Get Memory Allocation
	MALLOC=$((${MEMORY}*20/100))

	cat > /etc/sysconfig/varnish << EOF
	DAEMON_OPTS="-a :80 \
		-T localhost:6081 \
		-f /etc/varnish/default.vcl \
		-u varnish -g varnish \
		-S /etc/varnish/secret \
		-s malloc,${MALLOC}m"
EOF

	sed -i 's/.port = "80";/.port = "8080";/g' /etc/varnish/default.vcl

	# MariaDB
	## Tune MariaDB Server
	rm -f /etc/my.cnf.d/server.cnf

	if [[ ${MEMORY} -le 256 ]];
		then
		cp /usr/share/mysql/my-small.cnf /etc/my.cnf.d/server.cnf

	elif [[ ${MEMORY} -le 512 ]];
		then
		cp /usr/share/mysql/my-medium.cnf /etc/my.cnf.d/server.cnf

	elif [[ ${MEMORY} -ge 1000 ]];
		then
		cp /usr/share/mysql/my-large.cnf /etc/my.cnf.d/server.cnf
	fi

	## Secure DB and Set Root Password
	service mysql start && sleep 5

    echo "DELETE FROM mysql.user WHERE User='';" | mysql -u root
    echo "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';" | mysql -u root
    echo "DROP DATABASE test;" | mysql -u root
    echo "UPDATE mysql.user SET Password=PASSWORD('${PINCH_MARIADB_PASSWORD}') WHERE User='root';" | mysql -u root
    echo "FLUSH PRIVILEGES;" | mysql -u root

}

# Engage Pinch Services
function pinch_engage() {

	# Update Search Index
	updatedb

	# Ensure Services Boot on Startup
	chkconfig --add nginx && chkconfig nginx on
	chkconfig --add php-fpm && chkconfig php-fpm on
	chkconfig --add varnish && chkconfig varnish on
	chkconfig --add mysql && chkconfig mysql on
	chkconfig --add csf && chkconfig csf on
	chkconfig --add sendmail && chkconfig sendmail on
	chkconfig --add crond && chkconfig crond on

	# Launch Services
	service nginx restart
	service php-fpm restart
	service varnish restart
	service mysql restart
	service sshd restart
	service sendmail restart
	service crond start
	csf -r
}
