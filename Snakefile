def get_targets():
    import os
    folders = [f for f in os.scandir() if f.is_dir()]
    target_bases = []
    for hmm in (f for f in os.listdir('alldoms') if f.startswith('PF') and f.endswith('.hmm')):
        target_bases.append('alldoms/'+hmm.rsplit('.',1)[0])
    return [tb+'.full.fasta' for tb in target_bases]+[tb+'.hit.fasta' for tb in target_bases]

rule all:
    input: get_targets()

rule download_pfam_hmm:
    output:
        "alldoms/PF{pfam_num}.hmm"
    shell:
        "wget -O alldoms/PF{pfam_name}.hmm https://pfam.xfam.org/family/PF{pfam_num}/hmm"

include: "hmmer.Snakefile"
include: "fasta.Snakefile"
include: "alignment.Snakefile"