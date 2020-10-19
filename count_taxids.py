from collections import defaultdict
from tqdm import tqdm
from UniprotDB.UniprotDB import SeqDB
import json

s = SeqDB()
all_taxids = defaultdict(lambda: 0)
with open('uniprot.fasta') as i:
    pbar = tqdm()
    for l in i:
        if l.startswith(">"):
            sid = l[1:].strip()
            p = s[sid]
            all_taxids[int(p.annotations['ncbi_taxid'][0])] += 1
            pbar.update()
with open('uniprot_taxid_counts.json', 'w') as o:
    json.dump(all_taxids, o)
