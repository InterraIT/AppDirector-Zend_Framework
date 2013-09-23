#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://proxy.vmware.com:3128
export https_proxy=http://proxy.vmware.com:3128

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

# SCRIPT EXECUTION -- START

if [ -f /etc/redhat-release ] ; then
	echo "INSTALLING PHPUNIT FOR ZEND FRAMEWORK ..."
	# INSTALLING PHPUNIT
	pear config-set http_proxy $http_proxy
	pear upgrade pear
	pear channel-discover pear.phpunit.de
	pear channel-discover pear.symfony-project.com
	pear channel-discover components.ez.no
	pear install --force --alldeps channel://pear.php.net/HTTP_Request2-2.0.0RC1
	
	DIST=`cat /etc/redhat-release |sed s/\ release.*//`
	if [ "$DIST" = "Red Hat Enterprise Linux Server" ] ; then
		pear install --alldeps phpunit/PHPUnit
	else 
		pear install -a -f phpunit/PHPUnit
	fi
	echo "INSTALLATION OF PHPUNIT -- DONE"

else
	echo "INSTALLING PHPUNIT FOR ZEND FRAMEWORK ..."
	# INSTALLING PHPUNIT
	pear config-set http_proxy $http_proxy
	pear update-channels                           # updates channel definitions
	pear upgrade --alldeps                         # upgrades all existing packages and pear
	pear channel-discover components.ez.no         # this is needed for PHPUnit
	pear channel-discover pear.symfony-project.com # also needed by PHPUnit
	pear channel-discover pear.phpunit.de          # This IS phpunit
	pear install --alldeps phpunit/PHPUnit         # installs PHPUnit and all dependencies
	#phpunit --version
	echo "INSTALLATION OF PHPUNIT -- DONE"
fi

echo "CREATING NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND..."
cd $document_dir
zf create project $project_name
check_error "ERROR WHILE CREATING ZEND FRAMEWORK PROJECT"
echo "CREATION OF NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND -- DONE"

echo "CREATE LINK (SYMLINK)/COPY ZEND DIRECTORY FROM INSTALLATION PATH TO YOUR PROJECT DIRECTORY"
cd $document_dir/$project_name/library
#ln -s /usr/share/php/Zend . #IF INSTALLED FROM REPOSITORY
ln -s $install_path/ZendFramework/library/Zend/ .
#cp -r $install_path/ZendFramework/library/Zend/ .

# SCRIPT EXECUTION -- DONE