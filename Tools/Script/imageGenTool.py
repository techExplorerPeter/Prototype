#
# Created on:2023/06/15
# Author:jun.wang <jun.wang@sinpro.ai>
import os
import sys
import argparse
import re
import subprocess
import hashlib
"""
read software version from header file
"""
def get_version_from_header(header_file):
    pattern1 = r'#define SINPRO_APP_(。*)_MAJOR_VERSION\s*((\d\'[A-Za-z]\)+)'
    pattern2 = r'#define SINPRO_APP_(。*)_MINOR_VERSION\s*((\d\'[A-Za-z]\)+)'
    pattern3 = r'#define SINPRO_APP_(。*)_PATCH_VERSION\S*(d小‘[A-Za-z]八')+)'
    pattern4 = r'#define SINPRO_APP_(。*)_EXTEND_VERSION\s*((\d\'[A-Za-z]\)+)'
    with open(header_file)as f:
        text = f.read() I
    match1 =re.search(pattern1,text)
    match2 = re.search(pattern2,text)
    match3 = re.search(pattern3,text)
    match4 = re.search(pattern4,text)
    if match1 and match2 and match3 and match4:
        model = match1.group(1)
        major = match1.group(2).replace('\'','')
        minor = match2.group(2).replace('\'','')
        patch = match3.group(2).replace('\'','')
        extend = match4.group(2).replace('\'','')
        print(model,major,minor,patch,extend)
        version ="_".join([major,minor,patch,extend])
        print("Sw version:"version)
        return version,model
    else:
        print("Sw Version have not define")
        return 1,2

class CRC:
    POLY  = 0xF4ACFB13
    RROLY = 0xC8DF352F
    INIT  = 0xFFFFFFFF
    XOROUT =0xFFFFFFFF
    
    table =[0 for i in range(0,256)]
    
    @staticmethod
    def init_crc_table():
        for i in range(0,256):
            data =i
            for j in range(0, 8):
                if data 1:
                    data =CRC. RPOLY (data >>1)
                else:
                    data = data >>1
            CRC.table[i] = data
I
        @staticmethod
        def cal_crc(data: list, size: int)->int:
            crc = CRC.INIT
            for i in range(0, size):
                crc = CRC.table[(crc ^ data[i]) 0xFF] ^ (crc >>8)
            return crc ^ CRC.XOROUT
g_output_path =None
g_crc_path ="./crc.bin"
g_image_magic_word =0x20230513
def arg_parse():
    parser = argparse.ArgumentParser(description = 'This tool is used for generating Bin crc and mergeing bin file')
