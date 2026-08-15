nextflow.enable.dsl = 2

process DOWNLOAD_REFERENCE {
    container 'staphb/ncbi-datasets:16.15.0'
    publishDir 'results/reference', mode: 'copy'

    input:
    val accession

    output:
    path("${accession}.fasta")

    script:
    """
    datasets download genome accession ${accession} --include genome --filename ${accession}.zip

    unzip -j ${accession}.zip "ncbi_dataset/data/${accession}/*.fna"

    mv *.fna ${accession}.fasta
    """
}

//workflow {
 //   ref_ch = Channel.of('GCF_000146045.2')
//    DOWNLOAD_REFERENCE(ref_ch)
//    DOWNLOAD_REFERENCE.out.view()
//}
