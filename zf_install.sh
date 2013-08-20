#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# INTERNAL FUNCTIONS

# FUNCTION TO CHECK ERROR
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

# FUNCTION TO DISPLAY ERROR AND EXIT
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

# PARAMETER VALIDATION
echo "VALIDATING PARAMETERS..."
if [ "x${project_name}" = "x" ]; then
	error_exit "ZEND FRAMEWORK PROJECT TO BE CREATED NOT SET."
fi
echo "PARAMETERS VALIDATION -- DONE"

# SCRIPT EXECUTION -- START
if [ -f /etc/redhat-release ] ; then
	REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
	DIST=`cat /etc/redhat-release |sed s/\ release.*//`
	ARCH=`uname -p`
	if [ $ARCH == "i686" ] ; then
		echo "$DIST 32 BIT MACHINE - v$REV"
		basearch=i386
	else
		echo "$DIST 64 BIT MACHINE - v$REV"
		basearch=x86_64
		yum --nogpgcheck --noplugins -y clean all
	fi
	echo $REV | grep -q '6.'
	if [ $? -eq 0 ] ; then
		release=6
		subrelease=8
	else
		release=5
		subrelease=4
	fi
	
	# INSTALLING REMI REPOSITORY
	wget http://dl.fedoraproject.org/pub/epel/$release/$basearch/epel-release-$release-$subrelease.noarch.rpm
	rpm -Uvh epel-release-$release-$subrelease.noarch.rpm
	check_error "ERROR WHILE DOWNLOADING AND INSTALLING epel REPOSITORY"
	wget http://rpms.famillecollet.com/enterprise/remi-release-$release.rpm
	rpm -Uvh remi-release-$release.rpm
	check_error "ERROR WHILE DOWNLOADING AND INSTALLING remi REPOSITORY"
	
	if [ "$DIST" = "Red Hat Enterprise Linux Server" ] ; then
		sed -i "s|\$releasever|6|g" /etc/yum.repos.d/remi.repo
	fi
	
	echo "INSTALLING PRE-REQUISITES OF ZEND FRAMEWORK -- START"
	# INSTALLING APACHE, MYSQL AND PHP
	yum --enablerepo=remi install -y httpd mysql-server php php-common php-mysql php-pear php-xsl php-gd php-mbstring php-mcrypt 
	check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
	echo "INSTALLATION OF PRE-REQUISITES OF ZEND FRAMEWORK -- DONE"
	
	echo "INSTALLING ZEND FRAMEWORK FULL SETUP..."
	yum --enablerepo=remi install -y  php-ZendFramework
	check_error "ERROR WHILE INSTALLING ZEND FRAMEWORK FULL SETUP"
	echo "INSTALLATION OF ZEND FRAMEWORK -- DONE"		
	
	document_dir="/var/www/html"
else
	
	if [ -f /etc/SuSE-release ] ; then
		zypper ar -f http://download.opensuse.org/distribution/11.2/repo/oss/ repo-oss
		zypper ar -f http://download.opensuse.org/repositories/server:/monitoring/SLE_11.1 zend
		zypper --non-interactive --no-gpg-checks ref
		
		echo "INSTALLING PRE-REQUISITES OF ZEND FRAMEWORK ..."
		# INSTALLING APACHE, MYSQL AND PHP
		zypper --non-interactive --no-gpg-checks install apache2 mysql mysql-tools php5 php5-mysql php-pear php5-xsl php5-gd php5-mcrypt php5-mbstring apache2-mod_php5
		check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
		echo "INSTALLATION OF PRE-REQUISITES OF ZEND FRAMEWORK -- DONE"
		
		echo "INSTALLING ZEND FRAMEWORK FULL SETUP..."
		zypper --non-interactive --no-gpg-checks install php5-ZendFramework
		check_error "ERROR WHILE INSTALLING ZEND FRAMEWORK FULL SETUP"
		echo "INSTALLATION OF ZEND FRAMEWORK -- DONE"
		
		document_dir="/srv/www/htdocs"
	
	elif [ -f /etc/debian_version ] ; then
		apt-get -fy update
		apt-get -fy install
		apt-get -fy install linux-firmware
		
		echo "INSTALLING PRE-REQUISITES OF ZEND FRAMEWORK ..."
		# INSTALLING APACHE, MYSQL AND PHP
		apt-get --fix-missing -fy install apache2 mysql-client mysql-server php5 php5-cli php5-mysql php5-xsl php5-gd php5-mcrypt libapache2-mod-php5 libapache2-mod-auth-mysql php-pear
		check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
		echo "INSTALLATION OF PRE-REQUISITES OF ZEND FRAMEWORK -- DONE"
		
		echo "INSTALLING ZEND FRAMEWORK FULL SETUP..."
		apt-get --fix-missing -fy install zend-framework
		check_error "ERROR WHILE INSTALLING ZEND FRAMEWORK FULL SETUP"
		echo "INSTALLATION OF ZEND FRAMEWORK -- DONE"
		
		document_dir="/var/www"
	fi
fi
# SCRIPT EXECUTION -- DONE