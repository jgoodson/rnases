rule trim_alignment:
    container:
        "docker://jrgoodson/t_coffee_beta"
    input:
        "{file}.aln"
    output:
        "{file}.trim.aln"
    shell:
        "t_coffee -other_pg seq_reformat -in {input} -action +remove_seq unique +rm_gap 95  > {output}"


rule iqtree:
    container:
        "docker://jrgoodson/iqtree2"
    input:
        "{file}.trim.aln"
    output:
        "{file}.iqtree",
        "{file}."
    shell:
        "iqtree -m LG+G4 -s {input} -pre {wildcards.file} "
        "-nt AUTO -bb 1000 -bnni -nm 10000 -ninit 1000 --radius 20 -ntop 100 -nbest 10"