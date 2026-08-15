//nextflow.enable.dsl = 2

process FASTP {
    tag "$sample_id"
    container 'staphb/fastp:0.23.4'
    publishDir 'results/trimmed', mode: 'copy'

    input: tuple val(sample_id), file(reads1), file(reads2)

    output: tuple val(sample_id), path("${sample_id}_trimmed_1.fastq.gz"), path("${sample_id}_trimmed_2.fastq.gz"), emit: reads
    path("${sample_id}_fastp.json"), emit: json
    script:
    """
    fastp \
        -i ${reads1} -I ${reads2} \
        -o ${sample_id}_trimmed_1.fastq.gz -O ${sample_id}_trimmed_2.fastq.gz \
        --json ${sample_id}_fastp.json --html ${sample_id}_fastp.html
    """
}

//workflow {
 //   reads_ch = Channel.of(
 //       tuple('SRR2601843',
 //             file('results/raw_reads/SRR2601843_1.fastq.gz'),
 //             file('results/raw_reads/SRR2601843_2.fastq.gz'))
 //   )
 //   FASTP(reads_ch)
 //   FASTP.out.reads.view()
//}