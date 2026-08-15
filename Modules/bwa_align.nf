//nextflow.enable.dsl = 2

process BWA_ALIGN {
    tag "$sample_id"
    container 'staphb/bwa:0.7.17'
    publishDir "results/aligned"

    input: 
    tuple val(sample_id), path(reads1), path(reads2)
    tuple path(reference), path(amb), path(ann), path(bwt), path(pac), path(sa)

    output:
    tuple val(sample_id), path("${sample_id}.sam")

    script:
    """
    bwa mem -t ${task.cpus} ${reference} ${reads1} ${reads2} > ${sample_id}.sam
    """
}

//workflow {
//    reads_ch = Channel.of(
 //       tuple('SRR2584863',
  //            file('results/trimmed/SRR2601843_trimmed_1.fastq.gz'),
   //           file('results/trimmed/SRR2601843_trimmed_2.fastq.gz'))
   // )

 //   index_ch = Channel.of(
  //      tuple(file('results/reference/GCF_000146045.2.fasta'),
  //            file('results/reference/GCF_000146045.2.fasta.amb'),
   //           file('results/reference/GCF_000146045.2.fasta.ann'),
    //          file('results/reference/GCF_000146045.2.fasta.bwt'),
     //         file('results/reference/GCF_000146045.2.fasta.pac'),
      //        file('results/reference/GCF_000146045.2.fasta.sa'))
  //  )

  //  BWA_ALIGN(reads_ch, index_ch)
   // BWA_ALIGN.out.view()
//}