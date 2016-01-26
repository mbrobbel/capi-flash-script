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
                                                                        
# sudo ./capi-flash-fpga.sh <fpga-file>.dat

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

# need root
if [[ $EUID -ne 0 ]]; then
  printf "ERROR: This script must run as root\n"
  exit 1
fi

if [ $# -eq 0 ]; then
  printf "Input arguments missisng\nUsage: sudo capi-flash-fpga.sh <path-to-bit-file>\n"
fi

# check if file exit
if [[ ! -e $1 ]]; then
  printf "ERROR: $1 not found\n"
fi

FILENAME=$1

while read line; do
  p[$i]=$line
  i=$(( i + 1 ))
done < <(head -4 $FILENAME)

MAGIC_IN=${p[0]}
FILE_EXT=${p[1]}
DEVICE=${p[2]}
SUM_CHECK=${p[3]:0:32}
if [[ $MAGIC_IN != "2e4b454e" ]]; then
  printf "ERROR: Incorrect file format\n"
  exit
fi

MD5_SUM=`tail -n +5 $FILENAME | md5sum`
if [[ $SUM_CHECK = ${MD5_SUM:0:32} ]]; then
  tail -n +5 $FILENAME > ${FILENAME%.*}.$FILE_EXT
else
  printf "ERROR: File corrupt\n"
  exit
fi

${ROOT_DIR}/flash_script/capi-flash-script.sh ${FILENAME%.*}.$FILE_EXT $DEVICE

rm ${FILENAME%.*}.$FILE_EXT

