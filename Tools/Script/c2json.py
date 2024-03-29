import json
import re
import sys

module_name = sys.argv[2]

c_file_path = r'../build/'+module_name+'/BSW/GenData/Dem_Lcfg.c'
h_file_path = r'../build/'+module_name+'/BSW/GenData/Dem_Lcfg.h'

key1 = "DemEventParameter"
key2 = "EventTable"
key3 = "DtcTable"

def read_c():
    with open(c_file_path, mode='r') as f:
        with open(h_file_path, mode='r') as g:
            data = f.read() + g.read()
    return data

def define2dict(keywords):
    data = read_c()
    var = rf"#define DemConf_{keywords}_\w+\s+\d+"
    p = re.compile(var, re.S)
    list = (re.findall(p, data))
    
    d = {}
    for i in list:
        a = re.split(rf"DemConf_{keywords}_|\s+",i)
        a[a[-2]] = int(a[-1])
    return d

def getArray(keyword):
    data = read_c()
    patt1 = f'Dem_Cfg_{keyword}\[(\d+)\]'
    ret = re.search(patt1, data)
    if ret == None:
        num = 1
        return ret
    else:
        num = int(ret[1]) + 1
     patt2 = patt1 + ".*?)" * num 
     patt = re.compile(patt2, re.S)
     list = (re.search(patt, data))
     return list
 
 def getDict():
     define = define2dict(key1)
     Etable = getArray(key2)
     Dtable = getArray(key3)
     
     if Etable == None or Dtable == None or define == None:
         print("Davinci DTC Configuration Error!")
         sys.exit(-1)
     else:
        table_idx = re.findall(r'/* (Index.*) */', Etable[0])[0]
        table_idx = table_idx.split()
        Dtc_no = table_idx.index('DtcTableIdx') # find the DtcTableIdx (list)
        Etable_Match = []
        for line in re.findall('{(.*)}', Etable[0]):
            line = re.sub('(\/\*|\*\/|,)','',line)
            DtcTableIdx = line.split()[Dtc_no]
            DtcTableIdx = int(re.search('\d+', DtcTableIdx).group(0))
            Etable_Match.append(DtcTableIdx)
         
        EtableDict = {}
        for i in define.keys():
            EtableDict[i] = Etable_Match[define[i]]
            
        Dtable_Match = re.findall(r'0x\w+u', Dtable[0])
        dict = {}
        
        for i in EtableDict.keys():
            dict[i] = Dtable_Match[EtableDict[i]]
            # print(f"{i : 40}:{Dtable_Match[Etable_Match[define[i]]]}")             
        return dict
    #print(len(dict))
    #print(dict)
#with open('result.json','w') as h:
    #json.dump(dict,h)