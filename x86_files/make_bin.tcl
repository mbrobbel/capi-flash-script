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

set arg0 [lindex $argv 0]
set arg1 [lindex $argv 1]
set bit_file $arg0
set out_file $arg1

write_cfgmem -format bin -loadbit "up 0x0 $bit_file" -file $out_file -size 128 -interface BPIx16 -force
exit

