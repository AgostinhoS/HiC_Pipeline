nextflow.enable.dsl = 2

process DEDUP_PAIRS {
    tag "$sample_id"
    publishDir "results/pairs/dedup", mode: "copy"
    container "duplexa/4dn-hic:v43"

    input:
    tuple val(sample_id), path(sorted_pairsam)

    output:
    tuple val(sample_id), path("${sample_id}.dedup.pairsam.gz"), emit: dedup_pairsam
    tuple val(sample_id), path("${sample_id}.dedup.stats.txt"), emit: dedup_stats

    script:
    """
    pairtools dedup \
        --mark-dups \
        --output ${sample_id}.dedup.pairsam.gz \
        --output-stats ${sample_id}.dedup.stats.txt \
        ${sorted_pairsam}
    """
}

process STAT_PAIRS {
    tag "$sample_id"
    publishDir "results/pairs/stats", mode: "copy"
    container "duplexa/4dn-hic:v43"

    input:
    tuple val(sample_id), path(dedup_pairsam)

    output:
    tuple val(sample_id), path("${sample_id}.stats.txt"), emit: stats

    script:
    """
    pairtools stats \
        -o ${sample_id}.stats.txt \
        ${dedup_pairsam}
    """
}

//workflow {
//    ddpCh  = Channel.of(tuple("SRR2584863", file("results/pairs/SRR2584863.sorted.pairsam.gz")))
//    DEDUP_PAIRS(ddpCh)

//    STAT_PAIRS(DEDUP_PAIRS.out.dedup_pairsam)
//}
