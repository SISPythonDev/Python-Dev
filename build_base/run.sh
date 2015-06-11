#!/bin/bash

# OBJECTIVE TO THIS PROJECT IS TO INITIALIZE A PYTHON PROJECT. WE RUN THIS SCRIPT
# AND GET BUILD THE BASE FOR A PYTHON SCRIPT. IT IS NOT THAT MUCH WHAT WE CAN GET
# DONE BUT WE MAKE SURE THAT OUR PROJECTS HAVE THE VERY LESS INFORMATION EXPECTED
################################################################################

# WE SET A BUNCH OF DEFAULTS TO PREVENT ANY MISSING DATA THIS DATA IS NOT RELEVANT
# SO DEFAULTS CAN HAPPEN AND ACTUALLY IS NICE TO HAVE THEM ON HAND
# THERE IS THE OPTION OF USING A CONFIG FILE AS WELL :-)

AUTHOR="$(whoami)"
COPYRIGHT="$(hostname), $(date +%Y)"
CREDITS="$AUTHOR"
VERSION="0.1"
MAINTAINER="$AUTHOR"
EMAIL=""
STATUS="Development"

PROJECT=""
CONFIG=""

declare -A temporals
temporals=( ["AUTHOR"]="AUTHOR_" ["COPYRIGHT"]="COPYRIGHT_" ["CREDITS"]="CREDITS_"
            ["VERSION"]="VERSION_" ["MAINTAINER"]="MAINTAINER_" ["EMAIL"]="EMAIL_"
            ["STATUS"]="STATUS_" )

help(){
  echo "Usage mode:"
  echo "./$0 -p <projectname> [-c configuration file]"
}

input_config(){
  echo "Author name: "
  read AUTHOR_
  echo "Copyright (Author, YYYY): "
  read COPYRIGHT_
  echo "Credits (Author - Organization): "
  read CREDITS_
  echo "Version (1.0): "
  read VERSION_
  echo "Maintainer(s): "
  read MAINTAINER_
  echo "E-mail (maintainers_list@domain): "
  read EMAIL_
  echo "Status of the project (Dev,Test,Prod,...)"
  read STATUS_
}

not_empty(){
 VAR=$1
 TEMP=$2
 if [ "$(eval echo $TEMP)" != "" ]; then
   eval $VAR=$TEMP
 fi
}

copy_not_empty(){
  for item in ${!temporals[@]}; do
    not_empty $item \$${temporals["$item"]}
  done
}

while getopts "p:c:" opt; do
  case $opt in
    h)
      help;
      exit 0;
      ;;
    p)
      PROJECT=$OPTARG;
      ;;
    c)
      CONFIG=$OPTARG;
      ;;
    \?)
      echo "Invalid option: -$OPTARG";
      help;
      exit 1;
      ;;
  esac
done

if [ "$PROJECT" == "" ]; then
  echo "Project name was not defined, can't move on"
  exit 1
fi

if [ "$CONFIG" != "" ]; then
  if [ ! -e $CONFIG ]; then
    echo "Config file $CONFIG does not exist, do you wish to input your parameters manually? [y/N]"
    read ACTION
    ACTION=$(echo $ACTION | tr [:upper:][:lower;])
    if [ "$ACTION" != "y" ]; then
      exit 0
    else
      input_config
    fi
  else
    for item in ${!temporals[@]}; do
      if [ $item == "STATUS" ];then
        if [ "$STATUS_" == "" ]; then
          STATUS_=$STATUS
        fi
      else
        eval "${temporals["$item"]}=\"$(grep $item $CONFIG | awk -F= '{print $2}')\""
      fi
    done
  fi
else
  input_config
fi
copy_not_empty

PYMAIN="$PROJECT/src/__init__.py"
if [ -e $PYMAIN ]; then
  echo "Init file for this project already exists, can't move forward"
  exit 1
fi

# Trying to build using virtualenv
virtualenv $PROJECT 2>&1 1>/dev/null
if [ $? != 0 ]; then
  mkdir $PROJECT 2>/dev/null
  mkdir $PROJECT/lib 2>/dev/null
fi
mkdir $PROJECT/config 2>/dev/null
mkdir $PROJECT/src 2>/dev/null
mkdir $PROJECT/log 2>/dev/null
# Including XML files for using pyDev extension
SCRIPTNAME=$(basename "$0")
RUNPATH=$(echo $0 | sed -e "s/${SCRIPTNAME}//g")
XMLPATH="${RUNPATH}xml_templates"
cat ${XMLPATH}/project.xml | sed -e "s/@PROJECT@/${PROJECT}/g" > ./$PROJECT/.project
cp ${XMLPATH}/pydevproject.xml ./$PROJECT/.pydevproject

echo "Please add any comments about your project"
read COMMENTS
if [ "$COMMENTS" == "" ];then
  COMMENTS="$PROJECT"
else
  COMMENTS="$PROJECT - $COMMENTS"
fi

echo "# -*- coding: utf-8 -*-" > $PYMAIN
echo "" >> $PYMAIN
echo "\"\"\" $COMMENTS \"\"\"" >> $PYMAIN
echo "" >> $PYMAIN
echo "__author__     = \"$(echo $AUTHOR | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__copyright__  = \"$(echo $COPYRIGHT | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__credits__    = \"$(echo $CREDITS | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__credits__    = \"$(echo $VERSION | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__maintainer__ = \"$(echo $MAINTAINER | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__email__      = \"$(echo $EMAIL | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "__status__     = \"$(echo $STATUS | sed -e 's/\s+//g')\"" >> $PYMAIN
echo "" >> $PYMAIN
echo "def main():" >> $PYMAIN
echo "    pass #You will need to remove this one once you start coding" >> $PYMAIN
echo "" >> $PYMAIN
echo "if __name__ == \"__main__\":" >> $PYMAIN
echo "    main()" >> $PYMAIN

exit 0
