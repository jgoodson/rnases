def get_targets():
    import os
    folders = [f for f in os.scandir() if f.is_dir()]
    target_bases = []
    for hmm in (f for f in os.listdir('alldoms') if f.startswith('PF') and f.endswith('.hmm')):
        target_bases.append('alldoms/'+hmm.rsplit('.',1)[0])
    return [tb+'.full.fasta' for tb in target_bases]+[tb+'.hit.fasta' for tb in target_bases]

def get_seeds():
    import os
    folders = [f for f in os.scandir() if f.is_dir()]
    seeds = []
    for folder in folders:
        files = os.listdir(folder)
        for f in files:
            if f.endswith('.yaml'):
                seeds.append(folder.name+'/'+f)
    return seeds

def gen_res(seeds):
    hmms = []
    for seed in seeds:
        folder, yaml = seed.split('/')
        hmms.append(folder+'/'+yaml.split('.')[0]+'_seed.tc.expresso_uniprot.tblout')
    return hmms

rule all:
    input: get_targets()

rule seeds:
    input: gen_res(get_seeds())

rule clean:
    shell:
        "rm RNase_*/*.hmm* RNase_*/*_seed.*.aln RNase_*/*_seed.full.fasta RNase_*/*_seed.id || true"

rule download_pfam_hmm:
    output:
        "alldoms/PF{pfam_num}.hmm"
    shell:
        "wget -O alldoms/PF{pfam_name}.hmm https://pfam.xfam.org/family/PF{pfam_num}/hmm"

include: "hmmer.Snakefile"
include: "fasta.Snakefile"
include: "alignment.Snakefile"

