#!/bin/bash

# THIS SCRIPT WILL CHECK FOR SENSITIVE INFORMATION ACROSS YOUR CODE
# IT IS JUST A BUNCH OF GREPS ACTUALLY BUT IT IS NICE TO HAVE IT ALL
# TOGETHER ;-)

clear
CUSTOMER=""
PROJECT=""

help(){
  echo "Execution mode:"
  echo ""
  echo "$0 -c <Customer's name> -p <Project's name>"
}

while getopts c:p: opt; do
  case $opt in
    h)
      help;
      exit 0;
      ;;
    p)
      PROJECT=$OPTARG;
      ;;
    c)
      CUSTOMER=$OPTARG;
      ;;
    \?)
      echo "Invalid option: -$OPTARG";
      help;
      exit 1;
      ;;
  esac
done

if [ "$CUSTOMER" == "" ] || [ "$PROJECT" == "" ]; then
  echo "Missing information, validate your parameters"
  exit 1
fi

# Checking for KEYS
echo "Checking for keys"
echo $(tput setaf 1)
find $PROJECT -name "*.key"
find $PROJECT -name "*.cer"
find $PROJECT -name "*.crt"
find $PROJECT -name "*.pub"
echo $(tput sgr 0)
echo ""
echo "Checking for your customer's name in the code"
FINDCUSTOMER=$(grep -ir $CUSTOMER $PROJECT | grep -v grep)
if [ "$FINDCUSTOMER" != "" ]; then
  echo "Your customer's information is present in your code:"
  echo $(tput setaf 1)
  echo "$FINDCUSTOMER"
  echo $(tput sgr 0)
fi
echo ""
echo "Checking for RSA or PGP sensitive data"
FINDRSA=$(grep -r RSA $PROJECT | grep -v grep)
FINDPGP=$(grep -r PGP $PROJECT | grep -v grep)
if [ "$FINDRSA" != "" ]; then
  echo "Found some RSA references:"
  echo $(tput setaf 3) 
  echo "$FINDRSA"
  echo $(tput sgr 0)
fi
if [ "$FINDPGP" != "" ]; then
  echo "Found some PGP references:"
  echo $(tput setaf 3)
  echo "$FINDPGP"
  echo $(tput sgr 0)
fi
echo "Please validate none of the above are not hardcoded keys"
echo ""
echo "Clearing compiled files"
find $PROJECT -name "*.pyc" -delete
exit 0
