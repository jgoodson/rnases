# RNase/Dinucleotidase analysis pipeline

This is a Snakemake pipeline for the analysis of DnaQ-fold and DHH/DHHA1 family RNases to identify the presence and distribution of these protein sequences in all available genomes.

Running this pipeline requires installation of the appropriate Python libraries:
- snakemake
- jupyter
- matplotlib
- seaborn
- numpy

Additionally, this requires the following tools to be available in your Path:
- MMseqs2
- IQTREE2
- Hmmer3 (with Easel utilities)
- T-Coffee beta

Parts of this pipeline also require construction of a local Uniprot annotation mirror using (https://github.com/jgoodson/SeqDB) and installation of the corresponding library. 

