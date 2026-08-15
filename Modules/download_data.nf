nextflow.enable.dsl = 2

params.metadata_tsv = params.metadata_tsv
params.keypairs = params.keypairs ?: "${System.getProperty('user.home')}/keypairs.json"
params.outdir = "results"

process DOWNLOAD_TEST_DATA {
    tag "$url"
    container 'my-custom:latest' 
    publishDir 'results/raw_data', mode: 'copy'

    input: 
    val url
    path keypairs_json

    output:
    path "*", emit: files

    script:
    """
    KEY=\$(python3 -c "import json; print(json.load(open('${keypairs_json}'))['default']['key'])")
    SECRET=\$(python3 -c "import json; print(json.load(open('${keypairs_json}'))['default']['secret'])")
    curl -O -L --user \${KEY}:\${SECRET} "${url}"
    """
}

workflow {
    Channel
        .fromPath(params.metadata_tsv)
        .splitCsv(header: true, sep: '\t', skip: 0)
        .filter { row -> row.file_download_URL || row.href }
        .map { row -> row.file_download_URL ?: row.href }
        .set { urls_ch }

    keypairsCh = Channel.fromPath(params.keypairs)

    DOWNLOAD_TEST_DATA(urls_ch, keypairsCh)
}