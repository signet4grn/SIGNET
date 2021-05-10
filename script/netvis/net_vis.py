from pyvis.network import Network
import numpy as np
from IPython.display import IFrame
import pandas as pd
import sys
class NetVis:
 
    """ NetVis is a class for providing gene regulation network visualization
    
    Attributes:
        match_file_path: full path for the node information file
        edge_data_path: String, parent path for edgelist output 
        node_data_path: String, parent path for sub net node names
        save_file_path: String, parent path for the output '.html' file
    
    Properties:
        transcription_list: An array contains name of nodes with transcription factor
        edgelist: Pandas dataframe contains the information for edgelist
        nodes: An array of sub net nodes 
        
    Example:
        # initialization
        netVis = NetVis('./mart_export_protein_coding_37.txt','./res','./res','.')
        # visulize sub network
        netVis.visualizeSubNework(0.8,2)
        
    """

    def __init__(self, match_file_path, edge_data_path, node_data_path, save_file_path='.'):
        super()
        self.getTranscriptionList(match_file_path)
        self.edge_data_path = edge_data_path
        self.node_data_path = node_data_path
        self.save_file_path = save_file_path
        self.__nodes = []
        self.__edgelist = []
        
        return
    
    def loadEdgeData(self,freq):
        try:
            edgelist = pd.read_csv(self.edge_data_path +'/edgelist_'+str(freq),sep='\\s+')
        except:
            raise Exception('Wrong path or format for edge file')
            edgelist = []
        self.__edgelist = edgelist
        return edgelist
    
    def getTranscriptionList(self, filename):
        try:
            match_df = pd.read_csv(filename,sep='\t')
            match_df_transcription = match_df[match_df.iloc[:,7].str.contains("transcription(.*)factor").fillna(False)]
            transcription_list = np.unique(match_df_transcription['Gene name'] )
            self.__transcription_list = transcription_list
        except:
            raise Exception('Wrong path or format for match file')
            self.__transcription_list = []
        return 
    
    def getSubnetNodes(self, freq, sub_n):
        try:
            nodeNames = pd.read_csv(self.node_data_path+"/top"+str(sub_n)+"_freq_"+str(freq)+"_name.txt",header=None)
            nodeNames = nodeNames.values.reshape(-1)
        except:
            raise Exception('Wrong path or format for nodes file')
            nodeNames = []
        self.__nodes = nodeNames
        return nodeNames

    def selectSubNetEdges(self, edgelist, subnet_nodes):
        if(len(edgelist) and len(subnet_nodes)):
            sub_edgelist = edgelist[edgelist['source_gene_symbol'].isin(subnet_nodes) | edgelist['target_gene_symbol'].isin(subnet_nodes)]
            return sub_edgelist
        else:
            return []

    def visualizeSubNework(self, freq, sub_n):
        self.loadEdgeData(freq)
        self.getSubnetNodes(freq, sub_n)
        got_net = Network(width="950", directed=True,heading='')
        edgelist = self.selectSubNetEdges(self.__edgelist,self.__nodes)
        if(len(self.__nodes) and len(self.__edgelist)):
            for n in self.__nodes:
                trans_flag =  n in self.__transcription_list
                n_col = '#BF2C38' if trans_flag else '#ED80A7'
                got_net.add_node(n ,n, title= n+('[transcription factor]' if trans_flag else ''), color=n_col)
            for e in edgelist.values:
                src = e[0]
                dst = e[4]
                w = e[-1]
                col = '#D95252' if w<0 else '#68A694'
                got_net.add_edge(src, dst, color=col, title=src+(" down regulate " if w<0 else ' up regulate ')+dst)
            save_path = self.save_file_path+"/top"+str(sub_n)+"_freq"+str(freq)+".html"
            got_net.show(save_path)
            #return IFrame(save_path, width=900, height=600)
        else:
            return 'Nothing to be shown'
    
    @property
    def edgelist(self):
        return self.__edgelist
    @property
    def trancription_list(self):
        return self.__transcription_list
    @property
    def nodes(self):
        return self.__nodes


