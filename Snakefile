configfile: "pipeline_conf.yaml"

def get_seeds():
    import os
    folders = [f for f in os.scandir() if f.is_dir()]
    seeds = []
    for folder in folders:
        files = os.listdir(folder)
        for f in files:
            if f.endswith('.yaml'):
                seeds.append(f[:-5])
    return seeds

rule all:
    input:
        [f"RNase_all/clusterRes_final.full_0.{i}_rep_seq.tcr.mcoffee.aln" for i in range(3,8)]


rule clean:
    shell:
        "rm RNase_*/*.hmm* RNase_*/*.aln RNase_*/*.full.fasta RNase_*/*.id || true"

rule download_pfam_hmm:
    output:
        "alldoms/PF{pfam_num}.hmm"
    shell:
        "wget -O alldoms/PF{pfam_name}.hmm https://pfam.xfam.org/family/PF{pfam_num}/hmm"

include: "hmmer.Snakefile"
include: "fasta.Snakefile"
include: "alignment.Snakefile"
include: "mmseqs.Snakefile"

