# Pinch

Intelligent Stack Scripts for CentOS Linux
See [http://drewsymo.com/web-servers/baller-nginx-php-fpm-apc-mysql-install-script/](http://drewsymo.com/web-servers/baller-nginx-php-fpm-apc-mysql-install-script/) for more information.

## Installation

Pinch is a pinch to install, simply execute the following commands to get started:

	$ yum install -y git
	$ git clone git://github.com/drewsymo/Pinch.git
	$ cd Pinch/vanilla-lemp && bash install.sh

If you're on Linode, you can simply rebuild your instance with the `Pinch-installer` [stackscript](www.linode.com/stackscripts/).

## Features

* Installs a LEMP stack (PHP-FPM, MariaDB, APC, Nginx and Varnish Cache) via Yum
* Configures Varnish Cache with Nginx out-of-the-box
* Sets your hostname, timezone and installs essential tools
* Uses GoogleDNS with Level3 tertiary resolver
* Intelligentelly configures Nginx based on CPU cores
* Sets Varnish memory allocation percentage based on total memory
* Retrieves MariaDB server.cnf based on total memory
* Sets MariaDB root password and removes testing user / tables
* Creates a daily cron with email notifications for available Yum updates
* Secures your system via the following methods:
	* Creates privledged sudo user
	* Disable SSH root logins
	* Disables UseDNS
	* Change default SSH port
	* Enables SElinux
	* Firewall via CSF / iptables
	* Sets common network security parameters
	* Disables IPv6
	* Creates unprivledged www-data user for lemp components

## Documentation

### What are the PHP-FPM, Nginx, MariaDB and Varnish Locations?

The locations for each of the Pinch components are as follows:

* Nginx: `/etc/nginx`
* PHP-FPM: `/etc/php-fpm.d/`
* MariaDB: `/etc/my.cnf.d/`
* Varnish: `/etc/varnish/` & `/etc/sysconfig/varnish/`

### What is the Username and Password of my system?

Pinch creates a new privledged user for your system and disables root SSH logins for security. Additionally, it will set a root password for your MariaDB server.

* Hostname Option: `host.domain.com`
* Timezone Option: `Australia/NSW`
* New SSH Port: `3636`
* New Root Username: `sudoninja`
* New Root Password: `sudoninjapassword`
* MariaDB Root Password: `mariadbpassword`

For example, you can now login using `ssh -p 3636 sudoninja@x.x.x.x` with the password `sudoninjapassword`.

You can adjust the defaults by modifying the parameters in the `install.sh` script, located in the `vanilla-lemp` folder.
Alternatively, if you are using the Linode stack-script, you will be prompted to enter these options on rebuild.

## Author

**Drew Morris**

+ [Blog](http://drewsymo.com)
+ [Twitter](http://twitter.com/drewsymo)
+ [Google+](https://plus.google.com/u/0/114153589610660530694)
