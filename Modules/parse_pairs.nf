nextflow.enable.dsl = 2

process PARSE_PAIRS {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/pairs", mode: 'copy'

    input: tuple val(sample_id), path(sam_file)
    path chrom_sizes

    output: tuple val(sample_id), path("${sample_id}.pairsam.gz"), emit: pairsam

    script:
    """
    pairtools parse \\
    -c ${chrom_sizes} \\
    -o ${sample_id}.pairsam.gz \\
    ${sam_file}
    """
}

process SORT_PAIRS {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/pairs", mode: 'copy'
    

    input: tuple val(sample_id), path(pairsam)
    path(chrom_sizes)

    output: tuple val(sample_id), path("${sample_id}.sorted.pairsam.gz"), emit: sorted_pairs

    script:
    """
    pairtools sort --nproc 4 -o ${sample_id}.sorted.pairsam.gz ${pairsam}
    """
}

workflow {
    samCh   = Channel.of( tuple('SRR2584863', file("results/aligned/SRR2584863.sam")) )
    chromCh = Channel.of( file("results/chromsizes/reference.chrom.sizes") )


    PARSE_PAIRS(samCh, chromCh)
    PARSE_PAIRS.out.view()   


    SORT_PAIRS(PARSE_PAIRS.out.pairsam, chromCh)
    SORT_PAIRS.out.view()
}