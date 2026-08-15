nextflow.enable.dsl=2

process SELECT_PAIRS {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/dedup", mode: 'copy'

    input:
    tuple val(sample_id), path(dedup_pairsam)

    output:
    tuple val(sample_id), path("${sample_id}.filtered.pairsam.gz"), emit: filtered_pairsam

    script:
    """
    pairtools select '(pair_type == "UU")' ${dedup_pairsam} \
      | pairtools sort --memory 4G \
      | bgzip "-c" > ${sample_id}.filtered.pairsam.gz
    """
}


process INDEX_PAIRS {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/pairs", mode: 'copy'

    input:
    tuple val(sample_id), path("input.pairsam.gz")

    output:
    tuple val(sample_id), path("${sample_id}.filtered.pairsam.gz"), path("${sample_id}.filtered.pairsam.gz.px2"), emit: indexed_pairs

    script:
    """
    cp input.pairsam.gz ${sample_id}.filtered.pairsam.gz
    
    # -p pairs tells pairix to safely bypass the trailing SAM text blocks
    pairix -p pairs ${sample_id}.filtered.pairsam.gz
    """
}

process CLOAD_PAIRS {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/cool", mode: 'copy'

    input:
    tuple val(sample_id), path(pairsam), path(pairsam_index)
    path chrom_sizes
    val binsize

    output:
    tuple val(sample_id), path("${sample_id}.${binsize}.cool"), emit: cool

    script:
    """
    cooler cload pairix \
        -p 4 \
        ${chrom_sizes}:${binsize} \
        ${pairsam} \
        ${sample_id}.${binsize}.cool
    """
}

process EXTRACT_MATRIX {
    tag "$sample_id"
    container "duplexa/4dn-hic:v43"
    publishDir "results/matrix", mode: 'copy'

    input:
    tuple val(sample_id), path(cool_file)

    output:
    tuple val(sample_id), path("${sample_id}.matrix.npy"), emit: matrix

    script:
    """
    python3 <<EOF
    import cooler
    import numpy as np

    c = cooler.Cooler("${cool_file}")
    mat = c.matrix(balance=False)[:]
    np.save("${sample_id}.matrix.npy", mat)
    EOF
    """
}

process PLOT_HEATMAP {
    tag "$sample_id"
    container "hiccontainer:latest"
    publishDir "results/plots", mode: 'copy'

    input:
    tuple val(sample_id), path(matrix_npy)

    output:
    path "${sample_id}.heatmap.png"

    script:
    """
    pip install --quiet matplotlib numpy
    python3 <<EOF
    import numpy as np
    import matplotlib.pyplot as plt

    mat = np.load("${matrix_npy}")

    plt.figure(figsize=(8, 8))
    plt.imshow(np.log1p(mat), cmap='YlOrRd')
    plt.colorbar(label='log1p(counts)')
    plt.title("${sample_id} Hi-C contact map")
    plt.savefig("${sample_id}.heatmap.png", dpi=300)
    EOF
    """
}

//workflow {
 //   indxCh = Channel.of(tuple("SRR2584863", file("results/dedup/SRR2584863.dedup.pairsam.gz")))
 //   SELECT_PAIRS(indxCh)
  //  INDEX_PAIRS(SELECT_PAIRS.out.filtered_pairsam)

//    chromCh = Channel.fromPath("results/chromsizes/reference.chrom.sizes")
//    binCh   = Channel.of(100000)

//    CLOAD_PAIRS(INDEX_PAIRS.out.indexed_pairs, chromCh, binCh)

//    EXTRACT_MATRIX(CLOAD_PAIRS.out.cool)
//    PLOT_HEATMAP(EXTRACT_MATRIX.out.matrix)
//}