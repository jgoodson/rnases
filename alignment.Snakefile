rule basic_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tc.{mode}.aln"
    params:
        email="jgoodson@umd.edu"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {params.email} -run_name `mktemp -d`/run"

rule regressive_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tcr.{method}.aln"
    params:
        email="jgoodson@umd.edu"
    shell:
        "t_coffee -reg -seq {input:q} -reg_method {wildcards.method}.tc_method -reg_tree mbed -reg_nseq 100 -outfile {wildcards.file}.tcr.{wildcards.method}.aln -email {params.email} -run_name `mktemp -d`/run"

