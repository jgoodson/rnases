rule prep_uniprot:
    output:
        protected("uniprot.fasta")
    shell:
        """
        wget -O - ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz | gzip -dc | sed -E 's_^>\w{{2}}\|([A-Z0-9]{{6,10}})\|.*_>\\1_' > {output:q}
        wget -O - ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz | gzip -dc | sed -E 's_^>\w{{2}}\|([A-Z0-9]{{6,10}})\|.*_>\\1_' >> {output:q}
        """

rule sfetch_index:
    container:
        "docker://jrgoodson/hmmer"
    input:
        ancient("uniprot.fasta")
    output:
        protected("uniprot.fasta.ssi")
    shell:
        "esl-sfetch --index {input}"

rule extract_fasta_by_id:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "RNase_{rnase_name}/{file}.id",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "RNase_{rnase_name}/{file}.full.fasta"
    shell:
        "esl-sfetch -f {input[1]:q} {input[0]:q} > {output:q}"

wildcard_constraints:
    pfam_name="PF\w+",

rule extract_fasta_by_hits:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{pfam_name}.tblout",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "{pfam_name}.full.fasta"
    shell:
        "grep -v '^#' {input[0]:q} | awk '{{print $1}}' | uniq | esl-sfetch -f {input[1]:q} - > {output:q}"

rule extract_fragments_by_hits:
    container:
        "docker://jrgoodson/hmmer"
    input:
        "{pfam_name}.domtblout",
        "uniprot.fasta",
        "uniprot.fasta.ssi"
    output:
        "{pfam_name}.hit.fasta"
    shell:
        "grep -v '^#' {input[0]:q} | awk '{{print $1\"/\"$20\"-\"$21, $20, $21, $1}}' | esl-sfetch -Cf {input[1]:q} - > {output:q}"

rule gen_seedlist_from_yaml:
    input:
        file = "RNase_{rnase_name}/{rnase_name}.yaml"
    output:
        file = "RNase_{rnase_name}/{rnase_name}_seed.id"
    run:
        import yaml
        from UniprotDB.UniprotDB import SeqDB
        s = SeqDB(host=(config['seqdb_host']), on_demand=True)
        with open(input.file) as i:
            fam_info = yaml.safe_load(i)
        with open(output.file, 'w') as o:
            for example in fam_info['examples']:
                try:
                    o.write('{}\n'.format(s[example].id))
                except AttributeError:
                    print(example)
                    raise

rule combine_fasta:
    input:
        lambda wildcards: \
        [f"RNase_{rnase_name}/{rnase_name}_{{category}}.fasta" for rnase_name in get_family(wildcards.family)]
    output:
        "Family_{family}/{category}.fasta"
    shell:
        "cat {input} > {output}"