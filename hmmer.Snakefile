rule find_pfam_in_uniprot:
    input:
        "alldoms/PF{pfam_num}.hmm",
        "uniprot.fasta"
    output:
        multiext("alldoms/PF{pfam_num}", ".tblout", ".domtblout")
    threads: 2
    shell:
        "hmmsearch --tblout {output[0]:q} --domtblout {output[1]:q} -E 0.001 --cpu 4 {input:q} > /dev/null"

rule find_hmm_in_fasta:
    input:
        "{hmm_name}.hmm",
        "{fasta_name}.fasta"
    output:
        multiext("{hmm_name}_{fasta_name}", ".tblout", ".domtblout")
    threads: 2
    shell:
        "hmmsearch --tblout {output[0]:q} --domtblout {output[1]:q} -E 0.001 --cpu 4 {input:q} > /dev/null"


wildcard_constraints:
    method="\w+",
    rnase="RNase_\w+",
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
        "{rnase}/{protein}.{aligner}.{method}.hmm",
        "uniprot.fasta"
    output:
        "{rnase}/{protein}.{aligner}.{method}.jackhmmer.hmm"
    shell:
        "jackhmmer --incE 1e-25 {input[0]:q} {input[1]:q}"

rule press_hmm:
    input:
        "{file}.hmm"
    output:
        "{file}.hmm.h3m",
        "{file}.hmm.h3i",
        "{file}.hmm.h3f",
        "{file}.hmm.h3p"
    shell:
        "hmmpress {input:q}"
