import os
import sys
from pathlib import Path

sys.path.insert(0, Path(workflow.basedir).parent.parent.parent.parent.as_posix())
from constants.common import *

configfile: os.path.join(BASE_DIR, "config", "config.yaml")

# Directories
index_log_dir = os.path.join(BASE_DIR, "logs", "INDEX")

# Files
transcriptome = config['transcriptome']
transcript_name, _fa = os.path.splitext(transcriptome)
indexed_transcriptome = transcript_name + ".index"
index_log_file = os.path.join(index_log_dir, "index.log")

# Make any dir not available
os.makedirs(index_log_dir, exist_ok=True)

rule all:
    input:
        index_log_file,
        indexed_transcriptome 

rule kallisto_index:
    input:
        transcriptome
    output:
        indexed_transcriptome = transcript_name + ".index" 
    threads:
        config["threads"]
    log:
        index_log = index_log_file
    message:
        "Indexing {transcriptome} using kallisto"
    shell:
        """
        kallisto index -i {output} {input} &> {log.index_log}
        """
