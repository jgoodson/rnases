rule iqtree:
    container:
        "docker://jrgoodson/iqtree2"
    input:
        "{file}.aln_trim"
    output:
        "{file}.iqtree",
        "{file}.contree",
        "{file}.bionj",
        "{file}.ckp.gz",
        "{file}.log",
        "{file}.mldist",
        "{file}.splits.nex",
        "{file}.treefile",
        "{file}.ufboot"
    shell:
        "iqtree2 -m LG+G4 -s {input} -pre {wildcards.file} "
        "-nt AUTO -bb 1000 -bnni -nm 10000 --radius 20 -ntop 100 -nbest 10"

rule superfamily_tree:
    conda: "envs/notebook.yaml"
    input: "{file}.contree"
    output:
        "{file}.nwk",
        "{file}_families.txt",
    log: notebook = "logs/notebooks/Processed_superfamilytree_{file}.ipynb"
    notebook: "Notebooks/SuperfamilyTree.ipynb"