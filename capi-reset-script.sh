#!/bin/bash
#                                                                        
# IBM CAPI Flash Support 
#                                                                        
# Contributors Listed Below - COPYRIGHT 2015                        
# [+] International Business Machines Corp.                              
#                                                                        
#                                                                        
# Licensed under the Apache License, Version 2.0 (the "License");        
# you may not use this file except in compliance with the License.       
# You may obtain a copy of the License at                                
#                                                                        
#     http://www.apache.org/licenses/LICENSE-2.0                         
#                                                                        
# Unless required by applicable law or agreed to in writing, software    
# distributed under the License is distributed on an "AS IS" BASIS,      
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or        
# implied. See the License for the specific language governing           
# permissions and limitations under the License.  

# Usage: sudo capi-reset-script.sh <user/factory>

pwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

set -e

# output format
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# make sure script runs as root
if [[ $EUID -ne 0 ]]; then
  printf "${BOLD}ERROR:${NORMAL} This script must run as root\n"
  exit 1
fi

# check reset request
if [ $# -eq 1 ]; then
  if [ $1 != "user" ] && [ $1 != "factory" ]; then
    printf "${BOLD}:ERROR:${NORMAL} Can restore only user or factory image\n" 
    exit 1
  fi
fi

# get number of cards in system
n=`ls -d /sys/class/cxl/card* | awk -F"/sys/class/cxl/card" '{ print $2 }' | wc -w`

# print table header
printf "${bold}%-7s %-30s %-29s %-20s %s${normal}\n" "#" "Card" "Flashed" "by" "Image"

# print card information and flash history
i=0;
while read d; do
  p[$i]=$(cat /sys/class/cxl/card$i/psl_revision | xargs printf "%.4X");
  f=$(cat /var/cxl/card$i)
  while IFS='' read -r line || [[ -n $line ]]; do
    if [[ ${line:0:4} == ${p[$i]:0:4} ]]; then
      printf "%-7s %-30s %-29s %-20s %s\n" "card$i" "${line:5}" "${f:0:29}" "${f:30:20}" "${f:51}"
    fi
  done < "$pwd/psl-revisions"
  i=$[$i+1]
done < <(lspci -d "1014":"477" )

printf "\n"

# prompt card to reset
while true; do
  read -p "Which card do you want to reset? [0-$(($n - 1))] " c
  if ! [[ $c =~ ^[0-9]+$ ]]; then
    printf "${bold}ERROR:${normal} Invalid input\n"
  else
    c=$((10#$c))
    if (( "$c" >= "$n" )); then
      printf "${bold}ERROR:${normal} Wrong card number\n"
    else
      break
    fi
  fi
done

printf "Card$c set for reset\n"

# reset CAPI card
if [ $# -eq 0 ]; then
  printf user > /sys/class/cxl/card$c/load_image_on_perst
elif [ $1 == "factory" ]; then
  printf factory > /sys/class/cxl/card$c/load_image_on_perst
else
  printf user > /sys/class/cxl/card$c/load_image_on_perst
fi
printf 1 > /sys/class/cxl/card$c/reset
printf "Reset sent to card\n"
sleep 5

# wait for card to come up
while true; do
  if [[ `ls -d /sys/class/cxl/card* | awk -F"/sys/class/cxl/card" '{ print $2 }' | wc -w` == "$n" ]]; then
    break
  fi
  sleep 1
done
printf "Reset complete\n"

# remind afu to use in host application
printf "\nMake sure to use ${bold}/dev/cxl/afu$c.0d${normal} in your host application;\n\n"
printf "#define DEVICE \"/dev/cxl/afu$c.0d\"\n"
printf "struct cxl_afu_h *afu = cxl_afu_open_dev ((char*) (DEVICE));\n\n"  
 
