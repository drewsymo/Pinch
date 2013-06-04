#!/bin/bash -x

#
# drewsymo/Pinch
# Cron Job to Check for System Updates with Email Notifications
#
# @package Pinch 2.0
# @since Pinch 1.0
# @author Drew Morris
#

# Global Settings
YUMDATA=`yum check-update`
YUMSTATUS="${?}"
SENDEMAIL=0 # 0 = no, 1 = yes

# Delivery Settings
# Email can be changed to personal email, e.g. myemail@gmail.com
EMAIL="root"
FROM=`hostname`


if [ -f /var/lock/subsys/yum ]; then

        SUBJECT="Yum Check Failed"
        MESSAGE="We noticed Yum was running when we attempted to initiate the check, as such, the check was aborted. Will try again tomorrow."
        logger -t update-check "${MESSAGE}"
        SENDEMAIL=1

else

        if [[ ${YUMSTATUS} -eq "100" ]]; then
                SUBJECT="Updates Available on ${HOSTNAME}"
                MESSAGE="${HOSTNAME} has the update listed below available. These updates can be applied by running yum-update."
                logger -t update-check "Updates are available for this system via yum"
                SENDEMAIL=1

        elif [[ ${YUMSTATUS} -eq "0" ]]; then
                logger -t update-check "No updates available, the system appears up to date."

        else
                SUBJECT="Recieved Strange Return Code on ${HOSTNAME}"
                MESSAGE="We've recieved a strange return code from the yum-check. Perhaps you should manually check for updates. The code received was \"${YUMSTATUS}\""
                logger -t update-check "${MESSAGE}"
                SENDEMAIL=1

        fi

fi

if [[ ${SENDEMAIL} -eq "1" ]]; then

# Compile & Send Email
sendmail -t <<EOF
To: ${EMAIL}
Subject: ${SUBJECT}
From: ${FROM}

${MESSAGE}

${YUMDATA}

EOF

fi