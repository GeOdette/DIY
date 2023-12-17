import os
from pathlib import Path
import sys
BASE_DIR = Path(__file__).parent.parent

sample_dir = os.path.join(BASE_DIR, "data/")
sample_names = []
for file in os.listdir(sample_dir):
    try:
        if file.endswith(".fastq.gz"):
            sample_name = file.split(".fastq.gz")[0]
            sample_names.append(sample_name)
        elif file.endswith(".fastq"): 
            sample_name_ = file.split(".fastq")[0]
            sample_names.append(sample_name_)
    except FileNotFoundError:
        raise DataNotFoundError("Data not found in the data folder. Please correctly input the data in the data folder.")
