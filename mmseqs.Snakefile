rule cluster_seqs:
    input:
        "{subdir}/{name}.fasta"
    output:
        "{subdir}/clusterRes_{name}_{id}_cluster.tsv",
        "{subdir}/clusterRes_{name}_{id}_rep_seq.fasta",
        "{subdir}/clusterRes_{name}_{id}_all_seqs.fasta"
    threads: max(workflow.cores, 4)
    shell:
         "mmseqs easy-cluster --threads {threads} {input} "
         "{wildcards.subdir}/clusterRes_{wildcards.name}_{wildcards.id} "
         "tmp --min-seq-id {wildcards.id}"