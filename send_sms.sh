#!/bin/bash
# Script written to send SMS using Yota Ruby
# by Ahmed Sajid

PHONE_NUMBER=$1
MESSAGE=$2
YOTA_IP="10.0.0.1"
TIMESTAMP=`date +%s`
OUTPUT_FILE=`mktemp`
MIN_DIGITS=10

# Check if Yota ruby is attached
if ! cat /sys/bus/usb/devices/*/product | grep -q Ruby;then
	echo "Yota Ruby not attached!"
	exit 1
fi

# Check if Yota Ruby is reachable
ping -c 1 ${YOTA_IP}  -W 2 &> /dev/null
if [ $? -ne 0 ];then 
	echo "Cannot ping Yota Ruby at ${YOTA_IP}"
	exit 1
fi

# Enter Number and message
if [ -z $PHONE_NUMBER ] || [ -z "$MESSAGE" ];then
	echo "Usage: ./send_sms.sh <number> <Text>"
	exit 1
fi 

# Make sure that number is more than MIN_DIGITS digits
if [ ${#PHONE_NUMBER} -lt ${MIN_DIGITS} ];then
	echo "Please enter a correct phone number, at least ${MIN_DIGITS} digits"
	exit 1
fi

# Actual command to send SMS
curl "http://${YOTA_IP}/devcontrol?callback=jQuery1101025034334028150007_${TIMESTAMP}" -H "Host: ${YOTA_IP}" \
	-H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0' \
	-H 'Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01' \
	-H 'Accept-Language: en-US,en;q=0.5' \
	-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
	-H 'X-Requested-With: XMLHttpRequest' \
	-H "Referer: http://${YOTA_IP}/" \
	-H 'Cookie: YGlanguage=en' 	\
	-H 'Connection: keep-alive' \
	--compressed \
	--silent \
	--data "command=sendSms&phoneNumber=${PHONE_NUMBER}&text=${MESSAGE}" > ${OUTPUT_FILE}

# Check if the message was sent successfully by greping for true from the OUTPUT_FILE
if grep -q true ${OUTPUT_FILE};then
	echo "Message sent successfully to ${PHONE_NUMBER}"
else
	echo "Message sending failed"
	cat ${OUTPUT_FILE}
	exit 1
fi

# Remote the temporary output file
rm -rf ${OUTPUT_FILE}
