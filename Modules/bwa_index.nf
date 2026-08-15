nextflow.enable.dsl = 2

process BWA_INDEX {
    container 'staphb/bwa:0.7.17'
    publishDir 'results/reference', mode: 'copy'
    
    input: path(reference)

    output: tuple path(reference), path("${reference}.amb"), path("${reference}.ann"),
          path("${reference}.bwt"), path("${reference}.pac"), path("${reference}.sa")

    script:
    """
    bwa index ${reference}
    """
}

//workflow {
 //   reads_ch = Channel.of(file('results/reference/GCF_000146045.2.fasta'))
  //  BWA_INDEX(reads_ch)
  //  BWA_INDEX.out.view()
//}