#!/bin/bash
# This script queries the QRZ.com callsign database and returns
# the result to the command line. A XML subscription plan with 
# QRZ.com is required for full functionality.
#
# Copyright (C) 2020 Michael Clemens, DL6MHC
#
# usage: ./qrz.sh <callsign>


# get username and password from config file
. ~/.qrz.conf

# check if parameter has been supplied by user
if [ $# -ne 1 ]
  then
    echo "Error: You did not provide a callsign as parameter."
    echo "Usage: ./qrz.sh <callsign>"
    echo "Example: ./qrz.sh dl6mhc"
    exit
fi

# check if username/password is configured in config file
if [ -z ${user+x} ] || [ -z ${password+x} ]
  then
    echo "Error: Username and/or password have not been configured correctly."
    echo "       Please create the file ~/.qrz.conf with the following content:"
    echo "       ------------------------"
    echo "       user:<myusername>"
    echo "       password:<mypassword>"
    echo "       ------------------------"
    exit
  fi

# get callsign 
call=$1

# get a session key from qrz.com
session_xml=$(curl -s -X GET 'http://xmldata.qrz.com/xml/current/?username='${user}';password='${password}';agent=qrz_sh')

# check for login errors
#e=$(printf %s "$session_xml" | grep -oP "(?<=<Error>).*?(?=</Error>)" ) # only works with GNU grep
e=$(printf %s "$session_xml" | awk -v FS="(<Error>|<\/Error>)" '{print $2}' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g')
if [ "$e" != ""  ]
  then
    echo "The following error has occured: $e"
    exit
  fi

# extract session key from response
#session_key=$(printf %s "$session_xml" |grep -oP '(?<=<Key>).*?(?=</Key>)') # only works with GNU grep
session_key=$(printf %s "$session_xml" | awk -v FS="(<Key>|<\/Key>)" '{print $2}' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g')

# lookup callsign at qrz.com
lookup_result=$(curl -s -X GET 'http://xmldata.qrz.com/xml/current/?s='${session_key}';callsign='${call}'')

# check for login errors
#e=$(printf %s "$lookup_result" | grep -oP "(?<=<Error>).*?(?=</Error>)" ) # only works with GNU grep
e=$(printf %s "$lookup_result" | awk -v FS="(<Error>|<\/Error>)" '{print $2}' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g')
if [ "$e" != ""  ]
  then
    echo "$e"
    exit
  fi

# grep field values from xml and put them into variables
for f in "call" "fname" "name" "addr1" "addr2" "country" "grid" "email" "user" "lotw" "mqsl" "eqsl" "qslmgr"
do
  #z=$(printf %s "$lookup_result" | grep -oP "(?<=<${f}>).*?(?=</${f}>)" ) # only works with GNU grep
  z=$(printf %s "$lookup_result" | awk -v FS="(<${f}>|<\/${f}>)" '{print $2}' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g')
  eval "$f='${z}'";
done

# return extracted information to user
echo "================================================================"
echo "QRZ.com results for $call:"
echo "================================================================"
echo "Call:       $call"
echo "Name:       $fname $name"
echo "Street:     $addr1"
echo "City:       $addr2"
echo "Country:    $country"
echo "Grid:       $grid"
echo "EMail:      $email"
if [ "$call" != "$user" ]
  then
    echo "Manager:    $user"
  fi
echo ""
echo "================================================================"
echo "QSL Information"
echo "================================================================"
echo "QSL Info:   $qslmgr"
if [ "$eqsl" == "1" ]
  then
    echo "eQSL:       yes"
  fi
if [ "$lotw" == "1" ]
  then
    echo "LoTW:       yes"
  fi
if [ "$mqsl" == "1" ]
  then
    echo "Paper QSL:  yes"
  fi
