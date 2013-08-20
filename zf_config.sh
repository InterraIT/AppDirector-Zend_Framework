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

# SCRIPT EXECUTION -- START
if [ -f /etc/redhat-release ] ; then
	
	echo "INSTALLING PHPUNIT FOR ZEND FRAMEWORK ..."
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
	echo "INSTALLATION OF PHPUNIT -- DONE"
		
	echo "CREATING NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND..."
	cd $document_dir
	zf create project $project_name
	check_error "ERROR WHILE CREATING ZEND FRAMEWORK PROJECT"
	echo "CREATION OF NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND -- DONE"
	
	echo "CREATE LINK (SYMLINK) / COPY ZEND DIRECTORY TO YOUR PROJECT DIRECTORY"
	cd $document_dir/$project_name/library
	ln -s /usr/share/php/Zend .
else
	echo "INSTALLING PHPUNIT FOR ZEND FRAMEWORK ..."
	# INSTALLING PHPUNIT
	pear update-channels
	pear upgrade --alldeps
	pear channel-discover pear.phpunit.de
	pear channel-discover pear.symfony-project.com
	pear channel-discover components.ez.no
	pear install --alldeps phpunit/PHPUnit
	echo "INSTALLATION OF PHPUNIT -- DONE"
	
	echo "CREATING NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND -- START"
	cd $document_dir
	zf create project $project_name
	check_error "ERROR WHILE CREATING ZEND FRAMEWORK PROJECT"
	echo "CREATION OF NEW ZEND FRAMEWORK PROJECT USING ZF COMMAND -- DONE"
	
	echo "CREATE LINK (SYMLINK) / COPY ZEND DIRECTORY TO YOUR PROJECT DIRECTORY"
	cd $document_dir/$project_name/library
	if [ -f /etc/SuSE-release ] ; then
		ln -s /usr/share/php5/Zend .
	elif [ -f /etc/debian_version ] ; then
		ln -s /usr/share/php/libzend-framework-php/Zend/ .		
	fi
fi
# SCRIPT EXECUTION -- DONE