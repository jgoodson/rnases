rule basic_tcoffee_align:
    container:
        "docker://jrgoodson/t_coffee_beta"
    wildcard_constraints:
        fasta_type=".full|_rep_seq"
    input:
        "{file}{fasta_type}.fasta"
    output:
        "{file}{fasta_type}.tc.{mode}.aln"
    shadow: "shallow"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}{wildcards.fasta_type}.tc.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"

rule regressive_tcoffee_align:
    container:
        "docker://jrgoodson/t_coffee_beta"
    wildcard_constraints:
        fasta_type=".full|_rep_seq"
    input:
        "{file}{fasta_type}.fasta"
    output:
        "{file}{fasta_type}.tcr.{mode}.aln"
    threads: 4
    shadow: "shallow"
    shell:
        "t_coffee -reg -seq {input:q} -reg_method {wildcards.mode} -reg_tree mbed -reg_nseq 100 -reg_thread {threads} -outfile {wildcards.file}{wildcards.fasta_type}.tcr.{wildcards.mode}.aln -email {config[email]}"

rule adaptive_tcoffee_align:
    container:
        "docker://jrgoodson/t_coffee_beta"
    wildcard_constraints:
        fasta_type=".full|_rep_seq"
    input:
        "{file}{fasta_type}.fasta"
    output:
        "{file}{fasta_type}.tca.{mode}.aln"
    threads: 4
    shadow: "shallow"
    shell:
         "if [ `grep -c '>' {input}` -lt 200 ]; then "
         "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tca.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"
         "; else "
         "t_coffee -other_pg seq_reformat -in {input:q} -output fasta_seq | "
         "t_coffee -reg -seq stdin -reg_method {wildcards.mode} -reg_tree parttree -reg_nseq 100 -reg_thread {threads} -outfile {wildcards.file}{wildcards.fasta_type}.tca.{wildcards.mode}.aln -email {config[email]} -run_name `mktemp -d`/run"
         "; fi"

rule trim_align:
    container:
        "docker://jrgoodson/t_coffee_beta"
    input:
        "{file}.aln"
    output:
        "{file}.aln_trim"
    threads: 1
    shadow: "shallow"
    shell:
        "t_coffee -other_pg seq_reformat -in {input:q} -output fasta_aln -action +rm_gap 90 > {output:q}"