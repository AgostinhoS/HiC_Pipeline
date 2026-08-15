nextflow.enable.dsl=2

params.sra_id        = 'SRR2584863'
params.ref_accession = 'GCF_000146045.2'
params.outdir        = 'results'
params.metadata_tsv = "4DNESXTSP7H7_raw_files_2026-07-22-08h-45m.tsv"
params.keypairs = "/home/agost/keypairs.json"


include { DOWNLOAD_TEST_DATA } from './Modules/download_data.nf'
include { DOWNLOAD_REFERENCE } from './Modules/download_reference.nf'
include { CHROM_SIZE }         from './Modules/ref_chromsize.nf' 
include { FASTQC }             from './Modules/sra_fastqc.nf'
include { FASTP }              from './Modules/sra_fastp.nf'
include { BWA_INDEX }          from './Modules/bwa_index.nf'
include { BWA_ALIGN }          from './Modules/bwa_align.nf'

include { PARSE_PAIRS; SORT_PAIRS }  from './Modules/parse_pairs.nf'
include { DEDUP_PAIRS; STAT_PAIRS }  from './Modules/pairs_cleanup.nf'
include { SELECT_PAIRS; INDEX_PAIRS; CLOAD_PAIRS; EXTRACT_MATRIX; PLOT_HEATMAP } from './Modules/hic_visual.nf'


workflow{
    def slurp = new groovy.json.JsonSlurper()
    def file  = new File(params.keypairs)
    def keys  = slurp.parse(file)
    def fourdnKey = keys['default']['key']
    def fourdnSecret = keys['default']['secret']

    Channel
    .fromPath(params.metadata_tsv)
    .splitCsv(header: true, sep: '\t', skip: 1)
        .filter { row -> row.file_download_URL || row.href }   // adjust to your actual column
        .map { row -> row.file_download_URL ?: row.href }
        .set { urls_ch }
    readsCh = DOWNLOAD_TEST_DATA(urls_ch, fourdnKey, fourdnSecret, params.sra_id)
    readsCh.view()
    refCh = DOWNLOAD_REFERENCE(params.ref_accession)
    trimCh = FASTP(readsCh)
    idxCh = BWA_INDEX(refCh)
    alignCh = BWA_ALIGN(trimCh.reads, idxCh)

    chromCh = CHROM_SIZE(refCh)

    parseCh = PARSE_PAIRS(alignCh, chromCh)
    sortCh = SORT_PAIRS(parseCh, chromCh)
    dedupCh = DEDUP_PAIRS(sortCh)
    stCh = STAT_PAIRS(dedupCh.dedup_pairsam)
    filtCh = SELECT_PAIRS(dedupCh.dedup_pairsam)
    pCh = INDEX_PAIRS(filtCh.filtered_pairsam)
    clpCh = CLOAD_PAIRS(pCh.indexed_pairs, chromCh, 100000)
    mCh = EXTRACT_MATRIX(clpCh.cool)
    PLOT_HEATMAP(mCh)
}