configfile: "pipeline_conf.yaml"

from itertools import product

def get_seeds():
    import os
    folders = [f for f in os.scandir() if f.is_dir() and f.name.startswith('RNase_')]
    seeds = []
    for folder in folders:
        files = os.listdir(folder)
        for f in files:
            if f.endswith('.yaml'):
                seeds.append(f[:-5])
    return seeds

def get_family(family):
    import os
    import yaml
    folders = [f for f in os.scandir() if f.is_dir() and f.name.startswith('RNase_')]
    families = []
    for folder in folders:
        files = os.listdir(folder)
        for f in files:
            if f.endswith('.yaml'):
                with open(f'{folder.name}/{f}') as i:
                    fam_info = yaml.safe_load(i)
                if fam_info['family'] == family:
                    families.append(f[:-5])
    return families

def gen_res(seeds):
    hmms = []
    for seed in seeds:
        folder, yaml = 'RNase_'+seed, seed+'.yaml'
        hmms.append(folder+'/'+yaml.split('.')[0]+'_final.id')
    return hmms

rule seeds:
    input: gen_res(get_seeds())


rule all_combine:
    input:
        [f"Family_dnaq/clusterRes_final.full_0.{i}_rep_seq.tcr.mcoffee.tc_method.aln_trim" for i in range(3,8)]

rule indv_clusters:
    input:
        [f"RNase_{rnase}/clusterRes_{rnase}_final.full_0.{i}_cluster.tsv" for i, rnase in
         product([3,35,4,45,5,55,6,65,7,75,8,85,9,95], get_seeds())]

rule clean:
    shell:
        "rm RNase_*/*.hmm* RNase_*/*.aln RNase_*/*.full.fasta RNase_*/*.id RNase_*/clusterRes* RNase_*/*tblout || true"

rule download_pfam_hmm:
    output:
        "alldoms/PF{pfam_num}.hmm"
    shell:
        "wget -O alldoms/PF{pfam_name}.hmm https://pfam.xfam.org/family/PF{pfam_num}/hmm"

include: "hmmer.Snakefile"
include: "fasta.Snakefile"
include: "alignment.Snakefile"
include: "mmseqs.Snakefile"
include: "phylogenetics.Snakefile"
