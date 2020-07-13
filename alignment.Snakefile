rule basic_tcoffee_align:
    container:
        "docker://jrgoodson/t_coffee_beta"
    wildcard_constraints:
        fasta_type=".full|_rep_seq"
    input:
        "{file}{fasta_type}.fasta"
    output:
        "{file}{fasta_type}.tc.{mode}.aln"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"

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
    shell:
        "t_coffee -reg -seq {input:q} -reg_method {wildcards.mode}.tc_method -reg_tree parttree -reg_nseq 100 -thread={threads} -outfile {wildcards.file}.tcr.{wildcards.mode}.aln -email {config[email]} -run_name `mktemp -d`/run"

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
    shell:
         "if [ `grep -c '>' {input}` -lt 200 ]; then "
         "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"
         "; else "
         "t_coffee -reg -seq {input:q} -reg_method {wildcards.mode}.tc_method -reg_tree parttree -reg_nseq 100 -thread={threads} -outfile {wildcards.file}.tcr.{wildcards.mode}.aln -email {config[email]} -run_name `mktemp -d`/run"
         "; fi"