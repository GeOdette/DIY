# Load config file

import os
import sys
from pathlib import Path
sys.path.insert(0, Path(workflow.basedir).parent.parent.parent.parent.as_posix())
from constants.common import *
configfile: "workflows/rules/KALLISTO/QUANT/config.yaml"
configfile: os.path.join(BASE_DIR, "config", "config.yaml")
log_file = os.path.join(BASE_DIR, "logs", "subsample.log")
# Needed files
transcriptome = config["transcriptome"]
transcript_name, t_ext = os.path.splitext(transcriptome)

class DataNotFoundError(Exception):
    pass

# Directories
results_dir = os.path.join(BASE_DIR, "results")
quant_log_dir = os.path.join(BASE_DIR, "logs", "QUANT")
mapping_dir = os.path.join(BASE_DIR, "results", "mapping")
#os.makedirs
os.makedirs(results_dir, exist_ok=True)
os.makedirs(mapping_dir, exist_ok=True)

# Generating sample names

individual_sample_dirs = [os.path.join(BASE_DIR, "results", "mapping", str(sample_name)) for sample_name in sample_names]

rule all:
    input:
        individual_sample_dirs,
        log_file

_kallisto_cmd = ["kallisto", "quant"]

rule kallisto_map_quant:
    input:
        i_transcriptome = transcript_name + ".index",
        transcript= expand("{sample_dir}/{sample}.fastq.gz", sample=sample_names, sample_dir=sample_dir)

    output:
        individual_sample_dirs = directory([os.path.join(BASE_DIR, "results", "mapping", sample_name) for sample_name in sample_names]),
        log_file = [os.path.join(BASE_DIR, "logs", "QUANT", f"kallisto_{sample_name}.log") for sample_name in sample_names]

    threads: config["threads"]

    params:
        strand_length=config["strand_length"],
        std_deviation=config["std_deviation"]
    message:
        "Mapping reads to {input.i_transcriptome} using kallisto for sample"
    run:
        for fq_file in input.transcript:
            read = os.path.basename(fq_file).replace(".fastq.gz", "")
            individual_sample_dir = os.path.join(BASE_DIR, "results", "mapping", read)
            log_file = os.path.join(BASE_DIR, "logs", "QUANT", f"kallisto_{read}.log")
            if config["single_end"]:
                _cmd = " ".join(
                        _kallisto_cmd +
                        ["-i", input.i_transcriptome,
                        "-o", individual_sample_dir,
                        "-t", str(threads),
                        "--single",
                        "-l", str(params.strand_length),
                        "-s", str(params.std_deviation),
                        fq_file] + [f" &> {log_file}"]
                        ) 
            else:
                r2 = fq_file.replace(".fastq.gz", "_2.fastq.gz")
                _cmd = " ".join(
                            _kallisto_cmd +
                            ["-i", input.i_transcriptome,
                            "-o", individual_sample_dir,
                            "-t", str(threads),
                            fq_file, r2] +
                            [f"&> {log_file}"]
                        )
            shell(_cmd)
            shell(
                "echo '{cmd}' >> '{log_file}'".format(cmd=_cmd, log_file=log_file)
            )