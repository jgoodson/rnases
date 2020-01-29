def get_targets():
    import os
    folders = [f for f in os.scandir() if f.is_dir()]
    target_bases = []
    for hmm in (f for f in os.listdir('alldoms') if f.startswith('PF') and f.endswith('.hmm')):
        target_bases.append('alldoms/'+hmm.rsplit('.',1)[0])
    return [tb+'.full.fasta' for tb in target_bases]+[tb+'.hit.fasta' for tb in target_bases]

rule all:
    input: get_targets()

rule prep_uniprot:
    output:
        "uniprot.fasta"
    shell:
        """
        wget -O - ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz | gzip -dc | sed 's_^>\w\{2\}|\([A-Z0-9]\{6,10\}\)|.*_>\1_' >! {output:q}
        wget -O - ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz | gzip -dc | sed 's_^>\w\{2\}|\([A-Z0-9]\{6,10\}\)|.*_>\1_' >> {output:q}
        """

rule download_pfam_hmm:
    output:
        "alldoms/PF{pfam_num}.hmm"
    shell:
        "wget -O alldoms/PF{pfam_name}.hmm https://pfam.xfam.org/family/PF{pfam_num}/hmm"

rule find_pfam_in_uniprot:
    input:
        "alldoms/PF{pfam_num}.hmm",
        "uniprot.fasta"
    output:
        multiext("alldoms/PF{pfam_num}", ".tblout", ".domtblout")
    threads: 2
    shell:
        "hmmsearch --tblout {output[0]:q} --domtblout {output[1]:q} --cut_nc --cpu 4 {input:q} > /dev/null"

rule sfetch_index:
    input:
        "uniprot.fasta"
    output:
        "uniprot.fasta.ssi"
    shell:
        "esl-sfetch --index {input}"

rule extract_fasta_by_hits:
    input:
        "{pfam_name}.tblout",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "{pfam_name}.full.fasta"
    shell:
        "grep -v '^#' {input[0]:q} | awk '{{print $1}}' | uniq | esl-sfetch -f {input[1]:q} - > {output:q}"

rule extract_fragments_by_hits:
    input:
        "{pfam_name}.domtblout",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "{pfam_name}.hit.fasta"
    shell:
        "grep -v '^#' {input[0]:q} | awk '{{print $1\"/\"$20\"-\"$21, $20, $21, $1}}' | esl-sfetch -Cf {input[1]:q} - > {output:q}"

rule extract_fasta_by_seed:
    input:
        "{file}_seed.id",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "{file}_seed.full.fasta"
    shell:
        "esl-sfetch -f {input[1]:q} {input[0]:q} > {output}"

rule basic_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tc.{mode}.aln"
    params:
        email="jgoodson@umd.edu"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {params.email} -run_name `mktemp`"

wildcard_constraints:
    method="\w+",
    rnase="RNase \w+",
    aligner="\w+",
    protein="\w+"

rule build_hmm_from_examples:
    input:
        "{rnase}/{protein}.{aligner}.{method}.aln"
    output:
        "{rnase}/{protein}.{aligner}.{method}.hmm"
    shell:
        "hmmbuild {output:q} {input:q}"

rule jackhmmer_expand:
    input:
        "{rnase}/{protein}.{aligner}.{method}.hmm"
    output:
        "{rnase}/{protein}.{aligner}.{method}.jackhmmer.hmm"
    shell:
        "jackhmmer --incE 1e-25 "

rule press_hmm:
    input:
        "{file}.hmm"
    output:
        "{file}.hmm.h3f"
    shell:
        "hmmpress {input:q}"
