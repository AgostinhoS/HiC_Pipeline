nextflow.enable.dsl = 2

process CHROM_SIZE {
    container 'staphb/samtools:1.19'
    publishDir 'results/chromsizes'

    input: path(file)

    output: path("reference.chrom.sizes")
    
    script:
    """
    samtools faidx ${file}
    cut -f1,2 ${file}.fai > reference.chrom.sizes
    """
}

//workflow {
//    chrom_ch = Channel.fromPath("results/reference/GCF_000146045.2.fasta")
//    CHROM_SIZE(chrom_ch)
//}