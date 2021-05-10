import net_vis
import sys
import os

os.chdir("../../")  

args = sys.argv
freq = args[1]
ncount = int(args[2])
ninfo = str(args[3])

### NetVis(match_file_path, edge_data_path, node_data_path, save_file_path)  
netVis = net_vis.NetVis(ninfo,'./data/netvis','./data/netvis','./data/netvis')
for i in range(ncount):
	netVis.visualizeSubNework(freq,i+1)
#print(sys.argv[1])


