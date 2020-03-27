rule basic_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tc.{mode}.aln"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"

rule regressive_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tcr.{method}.aln"
    threads: 4
    shell:
        "t_coffee -reg -seq {input:q} -reg_method {wildcards.method}.tc_method -reg_tree mbed -reg_nseq 100 -reg_thread {threads} -outfile {wildcards.file}.tcr.{wildcards.method}.aln -email {config[email]} -run_name `mktemp -d`/run"

