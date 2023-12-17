import os
import sys
from pathlib import Path
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')
sys.path.insert(0, Path(workflow.basedir).parent.parent.parent.as_posix())
from constants.common import *
configfile: os.path.join(BASE_DIR, "workflows", "rules", "FASTQC", "config.yaml")
fastqc_out_dirs = [os.path.join(BASE_DIR, "results", "FASTQC", str(sample)) for sample in sample_names]
log_files = [os.path.join(BASE_DIR, "logs", "FASTQC" + f"fastqc_{sample}.log") for sample in sample_names]
rule all:
    input:
        fastqc_out_dirs,
        log_files

rule fastqc:
    input:
        fastq_files = expand(sample_dir + "{sample}.fastq.gz", sample = sample_names)

    output:
        fastqc_out_dirs = directory(fastqc_out_dirs),
        log_files = log_files
    threads:
        config['threads']
    message:
        "Running FASTQC..."

    run:
        for fastqc_file in input.fastq_files:
            read = os.path.basename(fastqc_file).replace(".fastq.gz", "")
            output_dir = os.path.join(BASE_DIR, "results", "FASTQC", read)
            os.makedirs(output_dir, exist_ok=True)
            log_file = os.path.join(BASE_DIR, "logs", "FASTQC", f"fastqc_{read}.log")
            _cmd = " ".join([
                "fastqc",
                "-o", output_dir,
                "-t", str(threads),
                "-q",
                fastqc_file
            ]) + f" &> {log_file}"
            logging.info(f'Running FASTQC for {read}')
            shell(_cmd)
            shell(f"echo '{_cmd}' >> '{log_file}'")
