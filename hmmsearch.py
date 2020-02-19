import pandas

domtblout_header = [
    'tname',
    'tacc',
    'tlen',
    'qname',
    'qacc',
    'qlen',
    'seq_E',
    'seq_score',
    'seq_bias',
    'dom_num',
    'dom_total',
    'dom_cE',
    'dom_iE',
    'dom_score',
    'dom_bias',
    'hmm_from',
    'hmm_to',
    'ali_from',
    'ali_to',
    'env_from',
    'env_to',
    'accuracy',
    'description'
]

tblout_header = [
    'tname',
    'tacc',
    'qname',
    'qacc',
    'seq_E',
    'seq_score',
    'seq_bias',
    'dom_E',
    'dom_score',
    'dom_bias',
    'dom_n_exp',
    'dom_n_reg',
    'dom_n_clu',
    'dom_n_ov',
    'dom_n_env',
    'dom_n_dom',
    'dom_n_rep',
    'dom_n_inc',
    'description'
]

def parse_hmmersearch(f, type=None):
    data = pandas.read_table(f, header=None, sep='\s+', comment='#')
    if f.endswith('.tblout') or type=='tblout':
        data.columns = tblout_header
    elif f.endswith('.domtblout') or type=='domtblout':
        data.columns = domtblout_header
    return data