params.indir = "/home/ubuntu/bulk_RNAseq/1st_project/raw_fastq_files/"
params.fastq_list = "/home/ubuntu/fastq_list.txt"
params.idx_folder = "/home/ubuntu/reference_genome/phiX174_genome/"
params.outdir = "/home/ubuntu/nextflow_test"
params.threads = 45

log.info """
         bowtie2 test (single file)
         ===================================
         indir        : ${params.indir}
         index        : ${params.idx_folder}
         fastq_list   : ${params.fastq_list}
         outdir       : ${params.outdir}
         """
         .stripIndent()

process remove_viral_reads {
    publishDir params.outdir, mode: 'copy'
  
    input:
      file(fastq_file)

    output:
      path "${fastq_file.simpleName}_cleaned.fastq.gz", emit: cleaned_fastq
      path "${fastq_file.simpleName}.bowtie2.report.txt", emit: report
      path "${fastq_file.simpleName}.bowtie2.alignment.txt", emit: alignment

    script:
    """
    idx_base=\$(find "${params.idx_folder}" -name '*.bt2' | sed 's/\\..*\$//' | sort -u)

    time taskset -c 0-44 bowtie2 -p ${params.threads} -k 1 --no-head --un-gz "${fastq_file.simpleName}_cleaned.fastq.gz" --very-sensitive-local -U "${fastq_file}" -x "\${idx_base}" 2> "${fastq_file.simpleName}.bowtie2.report.txt" | grep 'AS:' > "${fastq_file.simpleName}.bowtie2.alignment.txt"
    """
 }

workflow {
    fastq_list = file(params.fastq_list).readLines()
    fastq_channel = Channel.fromList(fastq_list)
    remove_viral_reads(fastq_channel)
    }
