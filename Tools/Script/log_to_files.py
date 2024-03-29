import re 
import matplotlib.pyplot as plt
import numpy as np
import math
import socket
import random
import re
dirct = {'RangeFFT' : [], 'dopplerFFT':[],'eachframe' : [], '2dfft' : [], 'cfar' : [], 'dve' : [], 'doa' : [], 'gPeakCnt' : [], 'pdNum':[]}

pattern = r'\[ (\w+) \], .* delta: (\d+)us'
pattern1 = r'\[ (\w+) \], (\d+) number'


# data_tmp = '\n[ RangeFFT ], now: 1520622245754064us, delta: 33824us\n\n[ dopplerFFT ], now: 1520622245758704us, delta: 4583us\n\n[ 2dfft ], now: 1520622245758718us, delta: 38507us\n\n[ cfar ], now: 1520622245759602us, delta: 884us\n[ gPeakCnt time ]50\n\n[ dve ], now: 1520622245763926us, delta: 4324us\n\n[ doa ], now: 1520622245766519us, delta: 2593us\n'
#should use "pip install matplotlib numpy"
start = 1
with open('./log_1103.txt','r') as f:
    for line in f:
        match = re.search(pattern, line)
        match1 = re.search(pattern1, line)
        if match:
            name = match.group(1)
            delta = match.group(2)
            # print(f"{name}: {delta}")
            if name in dirct:
                dirct[name].append(int(delta))
        if match1:
            name = match1.group(1)
            number = match1.group(2)
            if name in dirct:
                dirct[name].append(int(number))

# len = len(dirct['each frame'])
len = int(len(dirct['eachframe']))
x = np.arange(0, 2*len, 1)
xt = np.arange(0, len, 1)

y_RangeFFT = dirct['RangeFFT'][:2*len]
y_dopplerFFT = dirct['dopplerFFT'][:2*len]
y_2dfft = dirct['2dfft'][:2*len]
y_cfar = dirct['cfar'][:2*len]
y_dve = dirct['dve'][:2*len]
y_doa = dirct['doa'][:2*len]
y_gPeakCnt = dirct['gPeakCnt'][:2*len]
y_eachframe = dirct['eachframe'][:len]

window_size = 10
y_smooth_dve = np.convolve(y_dve, np.ones(window_size)/window_size, mode='same')
y_smooth_doa = np.convolve(y_doa, np.ones(window_size)/window_size, mode='same')
# z1 = [y3[i]/y5[i] for i in range(2*len)]
# z2 = [y4[i]/y5[i] for i in range(2*len)]
style = '-'
plt.figure()
plt.subplot(3,1,1)

plt.plot(x, y_RangeFFT, label='RangeFFT',linestyle = style)
plt.plot(x, y_dopplerFFT, label='dopplerFFT',linestyle = style)
plt.plot(x, y_2dfft, label='2dfft',linestyle = style)
plt.plot(x, y_cfar, label='cfar',linestyle = style)
plt.plot(x, y_smooth_dve, label='dve',linestyle = style)
plt.plot(x, y_smooth_doa, label='doa',linestyle = style)
plt.ylabel('us')
plt.legend()

y5_smooth_gPeakCnt = np.convolve(y_gPeakCnt, np.ones(window_size)/window_size, mode='same')
plt.subplot(3,1,2)
plt.plot(x, y5_smooth_gPeakCnt, label='single REF pointcloud number',linestyle = style)  
plt.legend()
y_smooth_eachframe = np.convolve(y_eachframe, np.ones(window_size)/window_size, mode='same')
plt.subplot(3,1,3)
plt.plot(xt, y_smooth_eachframe, label='one frame time')  
plt.ylabel('us')
plt.legend()

# plt.figure()
# z1_smooth = np.convolve(z1, np.ones(window_size)/window_size, mode='same')
# z2_smooth = np.convolve(z2, np.ones(window_size)/window_size, mode='same')
# plt.plot(x, z1_smooth, label='dve/pd',linestyle = style)
# plt.plot(x, z2_smooth, label='doa/pd',linestyle = style)
# plt.ylim(20,150)
# plt.ylabel('us')
# plt.legend()
plt.show()



# tcp_ip = '192.168.30.10'
# tcp_port = 11010
# buffer_size = 1024
# gap = 0
# s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# s.bind((tcp_ip, tcp_port))
# s.listen(1)
# conn, addr = s.accept()
# print('connect address:', addr)
# while 1:
#     data = conn.recv(buffer_size)
#     if data:
#         # print("receive data:", data)
#         sd = data.decode('ascii')
#         for match in re.finditer(pattern, sd):
#             name = match.group(1)
#             delta = match.group(2)
#             # print(f"{name}: {delta}")
#             if name in dirct:
#                 dirct[name].append(int(delta))
#             if name == 'eachframe':
#                 # print(f"{name}: {delta}")
#                 if gap == 0:
#                     gap = 1
#                 else:
#                     x.append(i)
#                     y_eachframe = dirct['eachframe'][:i]
#                     y_pdNum = dirct['pdNum'][:i]
#                     i=i+1
#                     # plt.clear()
#                     plt.subplot(2,1,1)
#                     plt.ylim(60000,200000)
#                     plt.plot(x,y_eachframe)
#                     plt.pause(0.1)
#                     plt.subplot(2,1,2)
#                     plt.plot(x,y_pdNum)
#                     plt.pause(0.1)
#         for match1 in re.finditer(pattern1, sd):
#             name = match1.group(1)
#             number = match1.group(2)
#             if name in dirct:
#                 dirct[name].append(int(number))
#             # if name == 'pdNum':
#                 # x.append(i)
#                 # y_rfft = dirct['RangeFFT'][:i]
#                 # y_dfft = dirct['dopplerFFT'][:i]
#                 # y_2dfft = dirct['2dfft'][:i]
#                 # y_cfar = dirct['cfar'][:i]
#                 # y_dve = dirct['dve'][:i]
#                 # y_doa = dirct['doa'][:i]
#                 # y_gPeakCnt = dirct['gPeakCnt'][:i]
#                 # y_eachframe = dirct['eachframe'][:i]
#                 # y_pdNum = dirct['pdNum'][:i]
#                 # i=i+1
#                 # ax.clear()
#                 # # ax.plot(x,y_rfft)
#                 # # ax.plot(x,y_dfft)
#                 # # ax.plot(x,y_2dfft)
#                 # # ax.plot(x,y_cfar)
#                 # # ax.plot(x,y_dve)
#                 # # ax.plot(x,y_doa)
#                 # # ax.plot(x,y_gPeakCnt)
#                 # ax.plot(x,y_eachframe)
#                 # # ax.plot(x,y_pdNum)
#                 # plt.pause(0.1)
# conn.close