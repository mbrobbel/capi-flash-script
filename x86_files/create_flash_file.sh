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

# ./create_flash_file.sh <bit-file>

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCES[0]}" )" && pwd )"

create_flash_file () {
  TEMP_FILE=${1##*/}
  FILE_EXT=${1##*.}
  OUTFILE="$ROOT_DIR/output/${TEMP_FILE%.*}.dat"
  mkdir -p $ROOT_DIR/output
  printf "%x%x%x%x\n" "0x2E" "0x4B" "0x45" "0x4E" > $OUTFILE
  printf "%s\n" $FILE_EXT >> $OUTFILE
  DEVICE=`${ROOT_DIR}/findDevice ${2}`;
  printf "%s\n" $DEVICE >> $OUTFILE
  check=`md5sum ${1}`;
  printf ${check:0:32}"\n" >> $OUTFILE
  cat $1 >> $OUTFILE
  printf "Flash file $OUTFILE created\n"
}

FILENAME=$1
FILE_EXT=${FILENAME##*.}

if [ $# -eq 0 ]; then
  printf "Input arguments missing\nUsage: create_flash_file.sh <bit-file>" 
fi
# check if file exist
if [[ ! -e $1 ]]; then
  printf "ERROR: $1 not found\n"
fi

if [ $FILE_EXT = "sof" ]; then
  printf "altera\n"
  quartus_cpf -c $FILENAME ${FILENAME%.*}.rbf
  create_flash_file ${FILENAME%.*}.rbf $FILENAME
  rm ${FILENAME%.*}.rbf

elif [ $FILE_EXT = "bit" ]; then
  printf "xilinx\n"
  vivado -nolog -nojournal -mode tcl -source make_bin.tcl -tclargs $FILENAME ${FILENAME%.*}.bin
  create_flash_file ${FILENAME%.*}.bin $FILENAME
  rm ${FILENAME%.*}.bin ${FILENAME%.*}.prm

else
  printf "ERROR: incorrect bitfile extension\n"
  exit
fi

