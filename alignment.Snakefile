rule basic_tcoffee_align:
    input:
        "{file}.full.fasta"
    output:
        "{file}.tc.{mode}.aln"
    params:
        email="jgoodson@umd.edu"
    shell:
        "t_coffee -seq {input:q} -mode {wildcards.mode} -pdb_type dn -outfile {wildcards.file}.tc.{wildcards.mode}.aln -output=fasta_aln -email {params.email} -run_name `mktemp`"

