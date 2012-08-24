#!/bin/bash
# - title        : Convert XEN Classic to XEN Server
# - description  : This script will allow you to convert a Cloud Image from XC to XS
# - author       : Kevin Carter
# - License      : GPLv3
# - date         : 2012-01-26
# - version      : 1.9
# - usage        : bash xc2xs.sh
# - notes        : This is a cloud files backup script.
# - bash_version : >= 3.2.48(1)-release
# - OS Supported : Debian, Ubuntu, Fedora, CentOS, RHEL, Arch, Gentoo
#### ========================================================================== ####
clear
echo "Version 1.9"

USERCHECK=$(whoami)
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as ROOT"
        echo "You have attempted to run this as $USERCHECK"
			echo "use sudo $0 $1 or change to root."
				exit 1
fi

LOCATION="$1"
USERNAME="$2"
APIKEY="$3"
CONTAINER="$4"
FILENAME="$5"

##  Exit  ##
QUITNOW(){
echo ''
	echo "Exiting the ${SCRIPTNAME}..."
		rm -rf ${AUTHFCF}
		rm -rf ${AUTHFILE}
		rm -rf ${FILELIST}
		rm -rf ${CONTAINERLIST}
		rm -rf ${LIST}
		rm -rf ${ERRORCHECK}
			exit $?
}

###  Help Messages  ###
HELP(){
clear
	echo "Welcome to the Help Section"
	echo ''
	echo "Available Commands"
	echo 'relist : This will RE-List the Containers and or Files'
	echo 'back   : If you are in a container, you can return to the container list'
	echo 'quit   : If you need to leave for any reason this will exit the script'
	echo ''
}

###  Message from Josh  ###
MSGFROMJOSH(){
	echo 'This is a Message from my colleague Josh Prewitt : '
	echo "If the new server isn't large enough to hold the stock image,"
	echo "the downloaded images from Cloud Files, AND the concatenated image,"
	echo "you may run out of disk space. For this reason, you might want to"
	echo "start with an 8GB (320GB VHD) or 16GB (640GB VHD) server and then"
	echo "downsize after you are done."
	echo ''
}

# Check the Location of the Users API Access #
SERVERLOCATION(){
if [ -z ${LOCATION} ];then
	echo -n "US or UK : "
		read LOCATION	
fi
	if [ -z ${LOCATION} ];then
		echo "No Location Specified"
			unset LOCATION
				SERVERLOCATION
					elif [ ${LOCATION} == "quit" ];then 
						QUITNOW
						elif [ ${LOCATION} == "help" ];then 
							HELP
								unset LOCATION
									SERVERLOCATION		
	fi
	
if [ ${LOCATION} = us ] || [ ${LOCATION} = US ]; then
	AUTHURL='https://auth.api.rackspacecloud.com/v1.0'
#		AUTHURL='https://auth.api.rackspacecloud.com/v2.0'
		elif [ ${LOCATION} = uk ] || [ ${LOCATION} = UK ]; then
			AUTHURL='https://lon.auth.api.rackspacecloud.com/v1.0'
#				AUTHURL='https://lon.auth.api.rackspacecloud.com/v2.0'
				else 
					clear
						echo "You did not specify one of the TWO Locations"
							unset LOCATION
								SERVERLOCATION
fi
}
##  Cloud Files Login and Authentication  ##
CLOUDFILES(){
clear
STORAGETOKEN=`grep "X-Storage-Token" ${AUTHFILE} | awk '{print $2}'`
	STORAGEURL=`grep "X-Storage-Url" ${AUTHFILE} | awk '{print $2}'`
		AUTHTOKEN=`grep "X-Auth-Token" ${AUTHFILE} | awk '{print $2}'`
		
#	STORAGETOKEN=`grep "access:token:id:" ${AUTHFILE} | awk -F ':' '{print $4}'`
#		AUTHTOKEN=`grep "access:token:id:" ${AUTHFILE} | awk -F ':' '{print $4}'`
#			MGTCDNURL=`grep "publicURL:https://cdn" ${AUTHFILE} | awk -F ':' '{print $2,$3}' | sed 's/ /:/g'`
				DATETODAY=`date +%y%m%d`
					curl -s -H "X-Storage-Token: ${STORAGETOKEN}" ${STORAGEURL} > ${CONTAINERLIST} 2>&1 
}

###  Enter the API Username  ###
ENTERUSERNAME(){
if [ -z ${USERNAME} ];then
	echo -n "What is your Cloud Control Panel Username : "
		read USERNAME
fi
	if [ -z $USERNAME ];then 
		echo "You have not specified a USERNAME, Please try again"
			ENTERUSERNAME
				elif [ ${USERNAME} == "quit" ];then 
					QUITNOW
						elif [ ${USERNAME} == "help" ];then 
							HELP
								unset USERNAME
									ENTERUSERNAME				
	fi
}

###  Enter the API Key  ###
ENTERAPIKEY(){
if [ -z ${APIKEY} ];then 
	echo -n "What is your API-KEY : "
		read APIKEY
fi		
	if [ -z ${APIKEY} ];then 
		echo "You have not specified an API-KEY, Please try again"
			ENTERAPIKEY
				elif [ ${APIKEY} == "quit" ];then 
					QUITNOW
						elif [ ${APIKEY} == "help" ];then 
							HELP
								unset APIKEY
									ENTERAPIKEY
	fi		

		if [ ! $(echo ${APIKEY} | wc -c) -gt 20 ];then 
			echo "Your API-KEY is not long enough or you did not put one, Please try again..."
				echo -n "What is your API-KEY : "
					read APIKEY
						ENTERAPIKEY
		fi
}

###  What is the container ###
WHATCONTAINER(){		
	curl -s -H "X-Storage-Token: ${STORAGETOKEN}" ${STORAGEURL} > ${CONTAINERLIST} 2>&1 
		if [ -z ${CONTAINER} ];then
			echo ''
				echo "Here are your Containers"
					echo "------------------------"
						cat ${CONTAINERLIST}
							echo '' 
								echo -n "What container is your image file in : "
									read CONTAINER
		fi
			if [ -z ${CONTAINER} ];then
				clear
					echo "You did not specify a container"
						echo ''
							unset CONTAINER
								WHATCONTAINER
			fi
				CHECKCONTAINER
}

###  Check the container  ###
CHECKCONTAINER(){
	if [ ${CONTAINER} == "relist" ];then 
		clear
			echo "The Containers Have Been ReListed"
				unset CONTAINER
					WHATCONTAINER
						elif [ ${CONTAINER} == "quit" ];then 
							QUITNOW
								elif [ ${CONTAINER} == "help" ];then 
									HELP
										unset CONTAINER
											WHATCONTAINER
	fi
		CONTNAME=`grep -x ${CONTAINER} ${CONTAINERLIST}`
			if [ -z ${CONTNAME} ];then 
				clear
					echo "The Container that you specified does not exist"
						unset CONTAINER
							unset CONTNAME
								WHATCONTAINER
			fi
				clear
					DOWNLOADFILENAME
}

# Check the Storage URL #
CONECTIONLOCATION(){
CONURL="${SOMEACTION}"
if [ -z ${SOMEACTION} ];then
	clear
	echo "Please Enter the location you are in"
	echo "	norm = Traffic over a public Network"
	echo "	snet = Traffic Over the Private Network"
		read -p "Where are you, NORM or SNET? : " CONURL	
fi
	if [ -z ${CONURL} ];then
		echo "No Conection Type Specified"
			unset CONURL
				CONECTIONLOCATION
					elif [ ${CONURL} == "quit" ];then 
						QUITNOW
						elif [ ${CONURL} == "help" ];then 
							HELP
								unset CONURL
									CONECTIONLOCATION		
	fi
	
if [ ${CONURL} = norm ] || [ ${CONURL} = NORM ]; then
	STORAGEURL=`grep "publicURL:https://storage" ${AUTHFILE} | awk -F ':' '{print $2,$3}' | sed 's/ /:/g'`
		elif [ ${CONURL} = snet ] || [ ${CONURL} = SNET ]; then
			STORAGEURL=`grep "internalURL:https://snet-storage" ${AUTHFILE} | awk -F ':' '{print $2,$3}' | sed 's/ /:/g'`
				else 
					clear
						echo "You did not specify one of the TWO Connection Types"
							unset CONURL
								CONECTIONLOCATION
fi
}

###  Download the file  ###
DOWNLOADFILENAME(){
curl -s -H "X-Storage-Token: ${STORAGETOKEN}" ${STORAGEURL}/${CONTAINER} > ${FILELIST}
	if [ -z ${FILENAME} ];then
		echo "***************************** IMPORTANT! *****************************"
		echo " If this is a chain, meaning there is more than 1 file named the same "
		echo "  Enter the name of your image file that you will be downloading.     "
		echo "             ENTER only ONE file name, we will get them all           "
		echo "***************************** IMPORTANT! *****************************"
		echo ''
			cat ${FILELIST}	| grep -v .yml | sed 's/.tar.gz.[0-9]//g'
				echo ''
					echo -n "Enter File Name : "
						read FILENAME
	fi
		if [ -z ${FILENAME} ];then 
			clear
				echo "The File that you specified does not exist"
					DOWNLOADFILENAME
		fi
			grep ${FILENAME} ${FILELIST} | grep -v '.yml' > ${DOWNLIST}
}
###  Download the Image File(s)  ###
DOWNLOADALLFILESFCF(){
	echo "Now Downloading the Origin OS from Cloud Files"
		cat ${DOWNLIST} | parallel -j+0 "curl -s -D - -H \"X-Storage-Token: $STORAGETOKEN\" ${STORAGEURL}/${CONTAINER}/{} -o ${XC2XSDLC}/{}"
}

###  Merge the image  ###
IMAGEMERGE(){
DLOWLOADEDFILES=$(ls ${XC2XSDLC}/${FILENAME}* | wc -l)
	if [ ${DLOWLOADEDFILES} != "1" ];then
		echo "Megring the Imaging"
			cat ${XC2XSDLC}/${FILENAME}* > ${XC2XS}/myimage.tar.gz
				else 
					mv ${XC2XSDLC}/${FILENAME}* ${XC2XS}/myimage.tar.gz
	fi
}

###  Check the system for Dependencies  ###
SYSTEMCHECK(){
echo "Checking to see if you have the Dependencies already installed..."
if [ ! `which make` ];then
	DEPENDS
fi
	if [ ! `which gcc` ];then
		DEPENDS
	fi
		if [ ! `which curl` ];then
			DEPENDS
		fi
			if [ ! `which parallel` ];then
				INSTALLPARALLEL
			fi
}

### Make the Temporary Files ###
MAKETEMPFILES(){
	echo "Making all of the Temp Files that we need"
		if [ `which mktemp` ];then 
			AUTHFCF=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			AUTHFILE=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			FILELIST=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			CONTAINERLIST=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			LIST=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			ERRORCHECK=`mktemp -t rsapi.XXXXXXXXXXXXXX`
			DOWNLIST=`mktemp -t dlfile.XXXXXXXXXXXXXX`
				elif [ `which tempfile` ];then
					AUTHFCF=`tempfile -s rsapi`
					AUTHFILE=`tempfile -s rsapi`
					FILELIST=`tempfile -s rsapi`
					CONTAINERLIST=`tempfile -s rsapi`
					LIST=`tempfile -s rsapi`
					ERRORCHECK=`tempfile -s rsapi`
					DOWNLIST=`tempfile -s dlfile`
						else
							if [ -d /tmp ];then
								TEMPDIRFILES="/tmp"
									else 
										TEMPDIRFILES="${RSAPI}"
							fi
								AUTHFCF="${TEMPDIRFILES}/authcf.tmp"
								AUTHFILE="${TEMPDIRFILES}/authfile.tmp"
								FILELIST="${TEMPDIRFILES}/filelist.tmp"
								CONTAINERLIST="${TEMPDIRFILES}/containerlist.tmp"
								LIST="${TEMPDIRFILES}/downlist.tmp"
								ERRORCHECK="${TEMPDIRFILES}/errorcheck.tmp"
								DOWNLIST="${TEMPDIRFILES}/dlfile.tmp"
		fi
}

###  Create the Directories needed  ###
MAKEDIRECTORIES(){
if [ ! -d ${XC2XS} ];then 
	echo "Creating the ${XC2XS} Directory"
		mkdir -p ${XC2XS}/temp
			cd ${XC2XS}
				else 
					echo "The ${XC2XS} exists, which means this script has been run before."
						read -p "Are you sure you want to continue? Press [ Enter ] To continue."
fi
	XC2XSDL="${XC2XS}/download"
		if [ ! -d ${XC2XSDL} ];then
			echo "Creating the ${XC2XSDL} Directory"
				mkdir -p ${XC2XSDL}
		fi
			XC2XSDLC="${XC2XSDL}/cURL"
				if [ ! -d ${XC2XSDLC} ];then
					echo "Creating the ${XC2XSDLC} Directory"
						mkdir -p ${XC2XSDLC}
				fi
					XC2XSLOG="${XC2XS}/log"
						if [ ! -d ${XC2XSLOG} ];then
							echo "Creating the ${XC2XSLOG} Directory"
								mkdir -p ${XC2XSLOG}
						fi
							XC2XSHOLD="${XC2XS}/holding"
								if [ ! -d ${XC2XSHOLD} ];then
									echo "Creating the ${XC2XSHOLD} Directory"
										mkdir -p ${XC2XSHOLD}
								fi
}

###  Build the needed Dependencies for TAR  ###
BUILDTAR(){
if [ ! -f ${XC2XS}/bin/tar ];then
	cd ${XC2XSDL}
		curl -s -C - http://ftp.gnu.org/gnu/tar/tar-latest.tar.gz -o ${XC2XSDL}/newtar.tar.gz
			tar xzf ${XC2XSDL}/newtar.tar.gz 
				cd ${XC2XSDL}/tar*
					./configure FORCE_UNSAFE_CONFIGURE=1 >> ${BUILDOFTAR} 2>&1
						make --silent install prefix=${XC2XS} >> ${BUILDOFTAR} 2>&1
							touch ${XC2XSDL}.tarnew
fi
}

### Allow tar to build in the background  ###
WAITBUILDTAR(){
echo -n "Waiting for our new version of tar to build "
if [ ! -f ${XC2XS}/bin/tar ];then
	WAITFORTAR(){
	if [ ! -f ${XC2XSDL}.tarnew ];then 
			echo -n "."
			sleep 2
			WAITFORTAR
	fi
	}
WAITFORTAR	
fi
echo "All Done!"
echo ''
echo "New TAR has been Built..."
}

###  Build the needed Dependencies for Parallel  ###
INSTALLPARALLEL(){
	echo "Installing Parallel"
		PARALLELFILE="parallel-20120122"
			curl -s -C - -O  "ftp://ftp.gnu.org/gnu/parallel/${PARALLELFILE}.tar.bz2"
				tar -xjpf ${PARALLELFILE}.tar.bz2
					cd ${PARALLELFILE}
						./configure
						make
						make install
}

# Ensure that you have the proper System Dependencies #
DEPENDS(){
echo "System Check"
if [ -f /etc/issue ];then
	RHEL=$(cat /etc/issue | grep -i '\(centos\)\|\(red\)\|\(fedora\)')
		DEBIAN=$(cat /etc/issue | grep -i '\(debian\)\|\(ubuntu\)')
			SUSE=$(cat /etc/issue | grep -i '\(suse\)')
				ARCH=$(cat /etc/issue | grep -i '\(arch\)')
					INSTALLLOG="${RSAPI}/DEPENDSINSTALL.log"
fi						
	if [ -f /etc/gentoo-release ];then
		GENTOO=$(cat /etc/gentoo-release | grep -i '\(gentoo\)')
	fi
		
	if [ -n "$RHEL" ];then
		echo "I see that you are on RHEL-ish type OS, too bad but ok here we go..."
			echo "Installing Dependencies..."
				yum install -y make gcc curl curl-devel > ${INSTALLLOG} 2>&1
					TRANSERROR=$(grep 'Transaction Check Error:' DEPENDSINSTALL.log)
		if [ "${TRANSERROR}" ];then
				yum downgrade -y openssl >> ${INSTALLLOG} 2>&1
				yum install -y make gcc curl curl-devel >> ${INSTALLLOG} 2>&1
		fi
		
			elif [ -n "$DEBIAN" ];then 
				echo "OK you are using a Debian type system, Good Job!"
					echo "Installing Dependencies..."
					apt-get update > ${INSTALLLOG} 2>&1
						apt-get -y install make libcurl4-openssl-dev gcc build-essential > ${INSTALLLOG} 2>&1
							elif [ -n "$SUSE" ];then
								echo "I see that you are on openSUSE, Not as good as Debian but better then RHEL-isht Distros..."
									echo "Installing Dependencies..."
										zypper refresh > ${INSTALLLOG} 2>&1
											zypper in -y make gcc curl curl-devel > ${INSTALLLOG} 2>&1
												elif [ -n "$GENTOO" ];then 
													echo "I see that you are using Gentoo, which is good... if you are into that sort of thing..."
														echo "There are no Dependencies to install."
															echo "make, gcc, and curl are installed by default."
																elif [ -n "$ARCH" ];then
																	echo "Ok... I see you are using Arch Linux... I am sorry, but here we go..."
																		echo "Installing Dependencies"
																			pacman -Sy --noconfirm make gcc curl > ${INSTALLLOG} 2>&1
																				else
																					clear
																						echo "I could not find your system type so you will have to figure out what is up"
																							echo "if you would like to have this migration completed automagicly."
																								exit 1
	fi
		INSTALLPARALLEL
}

###  Quit  ###
QUITNOW(){
echo "Killing all processes and removing temporary Files..."
	if [ -f /tmp/tarbuild ];then 
		rm /tmp/tarbuild
	fi
		rm -rf ${XC2XS}
			echo "Exiting the XC 2 XS Deployment Application"
				exit 1
}

###  Halt on Authentication ERROR  ###
ERRORCHECK(){
echo ''
echo "I am sorry though there was an error."
echo "Here is some Debug information..."
echo "You Specified your Location as : ${LOCATION}"
echo "You Specified your Username as : ${USERNAME}"
echo "You Specified your API Key  as : ${APIKEY}"
echo ''
echo "This is the error found when you tried to Authenticate :"
echo "${CHECK}"
echo ''
echo "All Temp and Log files are located at ${XC2XS}."
echo "Please refer to these files for more information"
	exit 1
}

###  Greeting  ###
XC2XSOPENER(){
echo ''
	echo "Hello and welcome to the XC 2 XS Script."
	echo "Script Location is $0"
	echo ''
	echo 'These are the uses of this script --'
	echo 'Main Goal, is to assist in the migration from Xen Classic to Xen Server.'
	echo 'This script is an interactive script, if you run the script, you will be'
	echo 'guided through the entire process.'
	echo ''
	echo 'While using the script you can use the help command.'
	echo 'This will show you the available options at any time.'
	echo ''
	echo 'If you know what image you want to deploy and the container it is in'
	echo 'You can avoid the interactivity with these commands from SHELL'
	echo "$0 <LOCATION> <USERNAME> <APIKEY> <CONTAINER> <FILE>"
	echo ''
}

###  Clean up the temp files  ###
DELETETEMPFILES(){
	echo "Doing some file Clean up"
		rm -f ${AUTHFCF} ${AUTHFILE} ${FILELIST} ${CONTAINERLIST} ${DOWNLIST} ${XC2XSDL}.tarnew 
}

###  Run the Script  ###
XC2XS='/root/XC2XS'
	COPY=$(which cp)
		if [ "$1" == "clean" ];then 
			echo "Removing the rebuild file so you can rebuild again."
			if [ -f /etc/XC2XS.rebuild ];then
				rm /etc/XC2XS.rebuild
			fi
				QUITNOW
					elif [ "$1" == "use" ];then
						XC2XSOPENER
							exit 1
		fi
			if [ -f /etc/XC2XS.rebuild ];then 
				echo "This Server has already been rebuilt, by the XC2XS Script"
					echo "If you wanted to rebuild this server again you should rebuild it from a vanilla Image."
						echo "Are you sure you want to proceed?"
							sleep 3
								read -p "Press [ Enter ] to Continue or [ CTRL-C ] to drop to the SHELL."
									rm /etc/XC2XS.rebuild
										else 
											echo "Warming up for Rebuild action..."
			fi
				XC2XSOPENER
					sleep 2
						MSGFROMJOSH
							sleep 5
								read -p "Press [ Enter ] To continue."
									MAKEDIRECTORIES

BUILDOFPARALLEL="${XC2XS}/log/buildofparallel.log"
	BUILDOFTAR="${XC2XS}/log/buildoftar.log"
		IMPORTANTBACKUP="${XC2XS}/log/IMPORTANTBACKUP.log"
			INCASEBACKUP="${XC2XS}/log/INCASEBACKUP.log"
				RECONSTRUCTION="${XC2XS}/log/RECONSTRUCTION.log"

SYSTEMCHECK
	MAKETEMPFILES

clear
	SERVERLOCATION
		ENTERUSERNAME
			ENTERAPIKEY
				CONECTIONLOCATION
					curl -s -D - -H "X-auth-User: ${USERNAME}" -H "X-Auth-Key: ${APIKEY}" ${AUTHURL} | col -b > ${AUTHFILE}

CHECK=`head -1 ${AUTHFILE} | grep '[3-9]\{1\}[0-9]\{2\}'`
	if [ "${CHECK}" ];then
		ERRORCHECK
	fi

CLOUDFILES
	WHATCONTAINER
		DOWNLOADFILENAME
			BUILDTAR & 
				DOWNLOADALLFILESFCF
					WAITBUILDTAR
						IMAGEMERGE

echo ''
	echo "Making a Backup of the servers important files"
		OLDTAR=`which tar`
			${COPY} -a /boot/ ${XC2XS}/XS.boot.initial > ${IMPORTANTBACKUP}.1 2>&1
				${COPY} -a /dev/ ${XC2XS}/XS.dev.initial > ${IMPORTANTBACKUP}.2 2>&1
					${COPY} -a /etc/ ${XC2XS}/XS.etc.initial > ${IMPORTANTBACKUP}.3 2>&1
						${OLDTAR} czf ${XC2XS}/XS.system.tar.gz /etc /boot /dev > ${IMPORTANTBACKUP}.4 2>&1

echo "Distributing the origin Operating System"
	NEWTAR="${XC2XS}/bin/tar"
		${NEWTAR} --strip-components=2 --hard-dereference -xpf ${XC2XS}/myimage.tar.gz -C /

echo "Backing up all of the new files that were just put into place"
	ORIGINSYSTEMFILE="${XC2XS}/systemfiles.tar.gz"
		USERSYSTEMFILES="${XC2XS}/log/useroriginsystemfiles.log"
			

find /etc/ -type f -name yum.conf -o -name shadow -o -name group -o -name passwd -o -name sudoers -o -name exports -o -name gshadow -o -name iptables* \
-o -name sources.list -o -name *.repo -o -name ssh* -o -name cron* -o -name syslog* -o -name logrotate* -o -name services > ${USERSYSTEMFILES}
	${NEWTAR} czf ${ORIGINSYSTEMFILE} `cat ${USERSYSTEMFILES}` > /dev/null 2>&1

echo "Now RE-Building the servers important files"
	${COPY} -af ${XC2XS}/XS.boot.initial/* /boot/ > ${RECONSTRUCTION}.1 2>&1
		${COPY} -af ${XC2XS}/XS.dev.initial/* /dev/ > ${RECONSTRUCTION}.2 2>&1
			${COPY} -af ${XC2XS}/XS.etc.initial/* /etc/ > ${RECONSTRUCTION}.3 2>&1
				rm -rf ${XC2XS}/XS.boot.initial ${XC2XS}/XS.dev.initial ${XC2XS}/XS.etc.initial

echo "Rebuilding Old Users, Groups, and configuration files"
	${NEWTAR} --hard-dereference -xpf ${ORIGINSYSTEMFILE} -C / > /dev/null 2>&1

echo 'Just a quick message from the creator of this script...

This was created by the hard work of several people.
This would not have possible without the input from

James Dewey
Josh Prewitt
Michael Quintero

This tool has been tested on Fedora, RHEL, CentOS, Debian, and Ubuntu.
However, this tool comes with no guarantees or warranties.

Have Fun!

Kevin Carter' > /etc/XC2XS.rebuild

RHEL=$(cat /etc/issue | grep -i '\(centos\)\|\(red\)\|\(fedora\)')
	if [ -n "$RHEL" ];then
		echo ''
			echo "Would you like the system to reset all of the permissions on the system for all of the installed RPMs?"

RHELISHPERMS(){
read -p "Please Enter [ YES ] or [ NO ] : " ANSWER
      case ${ANSWER} in

y | Y | yes | YES ) 
	echo ''
		echo "I have set a directive in the rc.local"
		echo "This will correct permissions based on the installed RPMs"
		echo "the Action will be done on Reboot."
		echo "Once the action finished it will delete itself from the rc.local"
		echo ''
		echo 'for p in $(rpm -qa); do rpm --setperms $p; done' >> /etc/rc.local
		echo 'for p in $(rpm -qa); do rpm --setugids $p; done' >> /etc/rc.local
		echo "sed -i '/^for/d' /etc/rc.local" >> /etc/rc.local
		echo "sed -i '/^sed/d' /etc/rc.local" >> /etc/rc.local
		echo "Remember that you have choosen to have all of the permissions reset."  
		echo "This will make the reboot process longer. So please be patient."
;;

n | N | no | NO ) 
	echo "All permissions for the System will be the same,"
	echo "as they were from when you deployed the file system."
;;

*) finish="-1";
	echo -n 'Invalid response -- ';
		RHELISHPERMS
;;

esac
}
		RHELISHPERMS
	fi

EMAILME(){
	if [ `which sendmail` ];then
		echo ''
		echo "Would you like to send some Usage data to me from the use of this script?"
		echo "All I am collecting is the Release info, the instance type, and the Diskspace being used."
		echo ''
			read -p "Please Enter [ YES ] or [ NO ] : " ANSWEREMAIL

case ${ANSWEREMAIL} in
	y | Y | yes | YES )
		SENDMAILAPPL=`which sendmail`
			echo ''
				echo "I will send you a copy of the message." 
					read -p "Enter your Email Address : " "CCEMAIL"
						read -p "Enter your first Name : " "USERNAMEEMAIL"
							echo ''

HOSTNAME=`hostname -f`
	if [ -f /etc/issue ];then 
		RELEASE=`head -1 /etc/issue`
			elif [ -f /etc/gentoo-release ];then
				RELEASE=`head -1 /etc/gentoo-release`
					else
						RELEASE="There was no issue file so I am not sure what Distro was used"
	fi
		
		EMAILNAME=`echo "${USERNAMEEMAIL}" | awk '{print $1}'`
echo "to:info@bkintegration.com
bcc:${CCEMAIL}
from:${EMAILNAME}@${HOSTNAME}
subject:Server ${HOSTNAME} Has used XC 2 XS

The Server ${HOSTNAME} has been successfully migrated using the XC 2 XS script

The Server Release  :
${RELEASE}

The Server instance :
`free -m | grep -i mem: | awk '{print $2}'`MB

The Servers Free Disk Space :
`df -h | head -2`

EOL" > mailme; ${SENDMAILAPPL} -t < mailme;rm mailme;
;;

	n | N | no | NO ) 
		echo "No Data has been transmitted," 
			echo "so no worries, maybe next time."
;;
		
	*) finish="-1";
		echo -n 'Invalid response -- ';
			EMAILME
;;
esac	    

	fi
}

EMAILME
	DELETETEMPFILES
	echo "All Done!"
	echo ''
	echo "****  READ ME PLEASE  ****"
	echo "The server has been rebuilt based on the image you have specified."
	echo "If something did not work right there are a bunch of files that logged the action"
	echo "All Backups and logs are located at :"
	echo "${XC2XS}"
	echo ''
	echo 'The Migration processes has finished, Please Remember :'
	echo "The Users and Passwords created on this server have been replaced, by the old servers information"
	echo "You will need to login with the other User Credentials."
	echo "There are a whole bunch of log files that are located in ${XC2XS}"
	echo "***   If you have some custom configuration somewhere in /etc/ you may need to restore it."
	echo "| |__ There are several TAR files in ${XC2XS}" 
	echo "|____ These files contain the Origin OS, use these tarballs to recover anything that may have been missed."
		sleep 5
			read -p "      Press [ Enter ] to Reboot or [ CTRL-C ] to drop to the SHELL."
				echo ''
				echo '---------- End Of Line ----------'
				cat /etc/XC2XS.rebuild
					sleep 4
						reboot
							exit 0
