//nextflow.enable.dsl = 2

process FASTQC {
    tag "$sample_id"
    container 'biocontainers/fastqc:v0.11.9_cv8'
    publishDir 'results/fastqc', mode: 'copy'

    input:
    tuple val(sample_id), path(reads1), path(reads2)

    output:
    path("*.zip"), emit: zip
    path("*.html"), emit: html

    script:
    """
    fastqc ${reads1} ${reads2}
    """
}

//workflow {
 //   reads_ch = Channel.of(
 //       tuple('SRR2601843',
 //             file('results/raw_reads/SRR2601843_1.fastq.gz'),
  //            file('results/raw_reads/SRR2601843_2.fastq.gz'))
  //  )
  //  FASTQC(reads_ch)
  //  FASTQC.out.html.view()
//}
// use command ls results/fastqc/ to see results