#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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
		subrelease=7
	else
		release=5
		subrelease=4
	fi
	# INSTALLING REMI REPOSITORY
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/$release/$basearch/epel-release-$release-$subrelease.noarch.rpm
	check_error "ERROR WHILE DOWNLOADING AND INSTALLING epel REPOSITORY"
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-$release.rpm
	check_error "ERROR WHILE DOWNLOADING AND INSTALLING remi REPOSITORY"
	if [ "$DIST" = "Red Hat Enterprise Linux Server" ] ; then
		sed -i "s|\$releasever|6|g" /etc/yum.repos.d/remi.repo
	fi
	echo "INSTALLING PRE-REQUISITES OF ZEND FRAMEWORK ..."
	# INSTALLING APACHE, MYSQL AND PHP
	yum --enablerepo=remi install -y httpd mysql-server php php-common php-mysql php-pear php-xsl php-gd php-mbstring php-mcrypt 
	check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
	# INSTALLING PHPUNIT
	pear upgrade pear
	pear channel-discover pear.phpunit.de
	pear channel-discover pear.symfony-project.com
	pear channel-discover components.ez.no
	pear install --force --alldeps channel://pear.php.net/HTTP_Request2-2.0.0RC1
	if [ "$DIST" = "Red Hat Enterprise Linux Server" ] ; then
		pear install --alldeps phpunit/PHPUnit
	else 
		pear install -a -f phpunit/PHPUnit
	fi
	echo "INSTALLATION OF PRE-REQUISITES -- DONE"
	
	echo "INSTALLING ZEND FRAMEWORK FULL SETUP..."
	yum --enablerepo=remi install -y  php-ZendFramework* --exclude php-ZendFramework-Db-Adapter-Oracle
	check_error "ERROR WHILE INSTALLING ZEND FRAMEWORK FULL SETUP"
	echo "INSTALLATION OF ZEND FRAMEWORK -- DONE"
else
	echo "INSTALLING PRE-REQUISITES OF ZEND FRAMEWORK ..."
	# INSTALLING APACHE, MYSQL AND PHP
	if [ -f /etc/SuSE-release ] ; then
		zypper ar -f http://download.opensuse.org/distribution/11.2/repo/oss/ repo-oss
		zypper --non-interactive --no-gpg-checks ref    
		zypper --non-interactive --no-gpg-checks install apache2 mysql mysql-tools php5 php5-mysql php-pear php5-xsl php5-gd php5-mcrypt php5-mbstring apache2-mod_php5
		check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
	
	elif [ -f /etc/debian_version ] ; then
		apt-get -fy update
		apt-get -fy install
		apt-get -fy install linux-firmware
		apt-get --fix-missing -fy install apache2 mysql-client mysql-server php5 php5-cli php5-mysql php5-xsl php5-gd php5-mcrypt libapache2-mod-php5 libapache2-mod-auth-mysql php-pear
		check_error "ERROR WHILE INSTALLING APACHE, MYSQL AND PHP"
	fi
	# INSTALLING PHPUNIT
	pear update-channels
	pear upgrade --alldeps
	pear channel-discover pear.phpunit.de
	pear channel-discover pear.symfony-project.com
	pear channel-discover components.ez.no
	pear install --alldeps phpunit/PHPUnit
	echo "INSTALLATION OF PRE-REQUISITES -- DONE"
	
	echo "INSTALLING ZEND FRAMEWORK ..."
	mkdir -p $install_path
	cd $install_path
	# DOWNLOADING THE ZEND FRAMEWORK INSTALLER
	wget $zf_url
	check_error "ERROR:WHILE DOWNLOADING THE ZEND FRAMEWORK INSTALLER"
	# EXTACTING THE ZEND FRAMEWORK INSTALLER
	ZEND_PACKAGE=`find $install_path -name "ZendFramework-*"`
	tar xvfz $ZEND_PACKAGE
	check_error "ERROR:WHILE EXTRACTING THE ZEND FRAMEWORK"
	rm -rf $ZEND_PACKAGE
	# RENAME THE DIRECTORY TO ZendFramework
	ZEND_PACKAGE=`find $install_path -name "ZendFramework-*"`
	mv $ZEND_PACKAGE ZendFramework
	check_error "ERROR:THERE IS NO SUCH DIRECTORY $ZEND_PACKAGE"
	# GIVE THE SUITABLE(read and execute) PERMISSION TO THE DIRECTORY"
	chmod -R 0755 ZendFramework/*
	# ENABLE THE ZF TOOL
	ln -s ${install_path}/ZendFramework/bin/zf.sh /usr/bin/zf
	check_error "ERROR:THERE IS NO SUCH DIRECTORY ${install_path}/ZendFramework"
	echo "INSTALLATION OF ZEND FRAMEWORK -- DONE"
fi
# SCRIPT EXECUTION -- DONE