import sys
args = sys.argv
freq = args[1]
ncount = int(args[2])

f = open("../../data/netvis/net.html",'w')
tabs = ""
for i in range(ncount):
	if i==0:
		tabs +=  '<input type="radio" name="tabset" id="tab'+str(i+1)+'" aria-controls="top"'+str(i+1)+' checked><label for="tab'+str(i+1)+'">Top '+str(i+1)+'</label>'
	else:
		tabs +=  '<input type="radio" name="tabset" id="tab'+str(i+1)+'" aria-controls="top'+str(i+1)+'" ><label for="tab'+str(i+1)+'">Top '+str(i+1)+'</label>'
		
contents = ""
for i in range(ncount):
	contents += '<section id="top'+str(i+1)+'" class="tab-panel">'+"<iframe class='net-frame' src='./top"+str(i+1)+"_freq"+freq+".html' width='1000' height='800' frameborder='no' border=0 marginwidth=0 marginheight=0 scrolling='no' allowtransparency='yes'></iframe></section>"	
	

message = """
<html>
<head>
	<link rel="stylesheet" href="./net.css"
</head>
<div class="tabset">
"""+ tabs +"""
  <div class="tab-panels">
   """+contents+"""
  </div>
  
</div>
</html>
"""

f.write(message)
f.close()
