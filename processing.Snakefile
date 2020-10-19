rule gen_presence_tree:
    conda: "envs/notebook.yaml"
    input: ['RNase_{s}/{s}_search.full.tcr.mcoffee.tc_method_uniprot.tblout'.format(s=s) for s in get_seeds()] +
           ['eukaryotes.txt', 'prokaryotes.txt', 'uniprot_taxid_counts.json']
    output: [f'allspectree_{l}.nwk' for l in ('class', 'order', 'family', 'genus')] +
            [f'allspectree_{l}.itol-rnase.txt' for l in ('class', 'order', 'family', 'genus')]
    log: notebook = "logs/notebooks/ProcessHitResults.ipynb"
    notebook: "Notebooks/ProcessHitResults.ipynb"

rule count_taxids:
    conda: "envs/notebook.yaml"
    output: "uniprot_taxid_counts.json"
    script: "count_taxids.py"

rule download_reports:
    output:
          "eukaryotes.txt",
          "prokaryotes.txt"
    shell:
         "wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt && wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/eukaryotes.txt"