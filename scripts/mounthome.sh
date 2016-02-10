#!/bin/bash

# Set variables

logfile="/Library/TT/Logs/mounthome.log"
		# Set the path to your log file
		
mount_protocol="smb"
		# Use "afp" or "smb"

# Create a log writing function

writelog()
{
	echo "${1}"	
	echo $(date) "${1}" >> $logfile
}

writelog "STARTING: User drive mount"

# Already mounted check

# The following checks confirm whether the user's personal network drive is already mounted,
# (exiting if it is).  If it is not already mounted, it checks if there is a mount point
# already in /Volumes.  If there is, it is deleted.

isMounted=`mount | grep -c "/Volumes/$USER"`

if [ $isMounted -ne 0 ] ; then
	writelog "Network share already mounted for $USER"
	exit 0
fi

# Get the SMBHome Attribute Value
writelog "Retrieving SMBHome attribute for $USER"

# Get Domain from full structure, cut the name and remove space.
ShortDomainName=`dscl /Active\ Directory/ -read . | grep SubNodes | sed 's|SubNodes: ||g'`

# Find the user's SMBHome attribue, strip the leading \\ and swap the remaining \ in the path to /
# The result is to turn smbhome: \\server.domain.com\path\to\home into server.domain.com/path/to/home
adHome=$(dscl /Active\ Directory/$ShortDomainName/All\ Domains -read /Users/$USER SMBHome | sed 's|SMBHome:||g' | sed 's/^[\\]*//' | sed 's:\\:/:g' | sed 's/ \/\///g' | tr -d '\n' | sed 's/ /%20/g')

# Next we perform a quick check to make sure that the SMBHome attribute is populated
case "$adHome" in 
 "" ) 
	writelog "ERROR: ${USER}'s SMBHome attribute does not have a value set. Exiting script."
	exit 1  ;;
 * ) 
	writelog "Active Directory users SMBHome attribute identified as $adHome"
	;;
esac

# Mount the network home
	mount_script=`/usr/bin/osascript > /dev/null << EOT
	mount volume "${mount_protocol}://${adHome}"
EOT`

writelog "Script complete"
# Script End

exit 0