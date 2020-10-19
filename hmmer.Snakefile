rule find_pfam_in_uniprot:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "alldoms/PF{pfam_num}.hmm",
        "uniprot.fasta"
    output:
        multiext("alldoms/PF{pfam_num}", ".tblout", ".domtblout")
    threads: 2
    shell:
        "hmmsearch --tblout {output[0]:q} --domtblout {output[1]:q} -E 0.001 --cpu 4 {input:q} > /dev/null"

rule find_hmm_in_fasta:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{hmm_name}.hmm",
        "{fasta_name}.fasta"
    output:
        multiext("{hmm_name}_{fasta_name}", ".tblout", ".domtblout")
    threads: 2
    shell:
        "hmmsearch --tblout {output[0]:q} --domtblout {output[1]:q} -E 0.001 --cpu 4 {input:q} > /dev/null"


wildcard_constraints:
    method="\w+\.?\w+",
    rnase="RNase_\w+",
    aligner="\w+",
    protein="\w+"

rule build_hmm_from_examples:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{f}.aln"
    output:
        "{f}.hmm"
    shell:
        "hmmbuild {output:q} {input:q}"

rule jackhmmer_expand:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{rnase}/{protein}.{aligner}.{method}.hmm",
        "uniprot.fasta"
    output:
        "{rnase}/{protein}.{aligner}.{method}.jackhmmer.hmm"
    shell:
        "jackhmmer --incE 1e-25 {input[0]:q} {input[1]:q}"

rule press_hmm:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{file}.hmm"
    output:
        "{file}.hmm.h3m",
        "{file}.hmm.h3i",
        "{file}.hmm.h3f",
        "{file}.hmm.h3p"
    shell:
        "hmmpress {input:q}"

rule process_seed_hits:
    conda: "envs/notebook.yaml"
    input: [f'RNase_{s}/{s}_seed.full.tc.mcoffee_uniprot.tblout' for s in get_seeds()]
    output: [f'RNase_{s}/{s}_search.id' for s in get_seeds()]
    params:
        outlabel="search"
    log: notebook = "logs/notebooks/Processed_ClassifyHits_seed.ipynb"
    notebook: "Notebooks/ClassifyHits.ipynb"

rule process_search_hits:
    conda: "envs/notebook.yaml"
    input: ['RNase_{s}/{s}_search.full.tcr.mcoffee.tc_method_uniprot.tblout'.format(s=s) for s in get_seeds()]
    output: ['RNase_{s}/{s}_final.id'.format(s=s) for s in get_seeds()]
    params:
        outlabel="final"
    log: notebook = "logs/notebooks/Processed_ClassifyHits_search.ipynb"
    notebook: "Notebooks/ClassifyHits.ipynb"