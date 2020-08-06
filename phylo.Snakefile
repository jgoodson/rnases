rule run_iqtree:
    container:
        "docker://jrgoodson/t_coffee_beta"
    wildcard_constraints:
        aln_type=".aln|_rep_seq"
    input:
        "{file}{fasta_type}.fasta"
    output:
        "{file}{fasta_type}.tc.{mode}.aln"
    shadow: "shallow"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}{wildcards.fasta_type}.tc.{wildcards.mode}.aln -output=fasta_aln -email {config[email]} -run_name `mktemp -d`/run"
