#!/bin/bash

#
CLEAR='\033[0m'
RED='\033[0;31m'

function usage() {
  if [ -n "$1" ]; then
    echo -e "${RED}👉 $1${CLEAR}\n";
  fi
    echo "Usage: $0 [-i input-dir] [-o output-dir] [-c cores] [-s file-suffix] [-f file-names] [-p --pattern] [-r --recursive] [-t  --r-script]"
    echo "  -i, --input-dir  : Full path to the directory containing input files"
    echo "  -o, --output-dir   : Full path to the directory for output files. Will be created in working directory if it does not exist [default antismash_output]"
    echo "  -c, --cores        : Number of CPU cores to use [default 1]"
    echo "  -s, --file-suffix  : Option 1: File extension for one or more input genome fasta files [default .fa]"
    echo "  -f, --file-names   : Option 2: Comma-separated names of specific files in input directory (note: no spaces between commas!)"
    echo "  -p, --pattern      : Regex file pattern for antiSMASH output cluster Genbank files [default .*region.*.gbk]"
    echo "  -r, --recursive    : Should all folders in the current directory be recursively searched for Genbank cluster files? (TRUE/FALSE) [default TRUE]"
    echo "  -t, --r-script     : Full path to the pipeline R script"
    echo ""
    echo "Note: use either Option 1 or Option 2 for input files"
    echo ""
    echo "Example of Option 1 with long flags: $0 --input-dir /path/to/input_files --output-dir /path/to/output_dir --cores 1 --file-suffix .fa --r-script /path/to/r-script"
    echo "Example of Option 1 with short flags: $0 -i /path/to/input_files -o /path/to/output_dir -c 1 -s .fa -t /path/to/r-script"
    echo ""
    echo "Example of Option 2 with long flags: $0 --input-dir /path/to/input_files --output-dir /path/to/output_dir --cores 1 --file-names genome_fasta_1.fa,genome_fasta_2.fa --r-script /path/to/r-script"
    echo "Example of Option 2 with short flags: $0 -i /path/to/input_files -o /path/to/output_dir -c 1 -f genome_fasta_1.fa,genome_fasta_2.fa -t /path/to/r-script"
    exit 1
}

#parse parameters
while [[ "$#" > 0 ]]; do case $1 in
  -i|--input-dir) INPUT_DIR="$2"; shift;shift;;
  -o|--output-dir) OUTPUT_DIR="$2"; shift;shift;;
  -c|--cores) CORES="$2"; shift;shift;;
  -s|--file-suffix) SUFFIX="$2"; shift;shift;;
  -f|--file-names) FILES="$2"; shift;shift;;
  -p|--pattern) PATTERN="$2"; shift;shift;;
  -r|--recursive) RECURSIVE="$2"; shift;shift;;
  -t|--r-script) SCRIPT_PATH="$2"; shift;shift;;

  *) usage "Unknown parameter passed $1"; shift;shift;;
esac; done

#verify parameters
if [ -z "${INPUT_DIR}" ]; then usage "Error: please provide the full path to the input directory"; exit 1; fi;
if [ -z "${OUTPUT_DIR}" ]; then OUTPUT_DIR=$(echo "antismash_output"); fi;
if [ -z "${CORES}" ]; then CORES=$(echo 1); fi;
if [ -z "${SUFFIX}" ] && [ -z "${FILES}" ]; then usage "Error: did not detect file extension pattern or file names. Please provide either a file extension regex pattern or comma-separated file names"; exit 1; fi;
if [ -n "${SUFFIX}" ] && [ -n "${FILES}" ]; then usage "Error: detected file extension pattern and file names. Please provide either a file extension regex pattern or comma-separated file names"; exit 1; fi;
if [ -z "${PATTERN}" ]; then PATTERN=$(echo ".*region.*.gbk"); fi;
if [ -z "${RECURSIVE}" ]; then RECURSIVE=$(echo "TRUE"); fi;
if [ -z "${SCRIPT_PATH}" ]; then usage "Error: please provide the full path to the pipeline R script"; exit 1; fi;



#load conda environment containing antiSMASH 6.0.0
module load anaconda/5.1
source activate anti6

#
if [ -d "${OUTPUT_DIR}" ]; then cd "${OUTPUT_DIR}"
else mkdir "${OUTPUT_DIR}"; cd "${OUTPUT_DIR}"; OUTPUT_DIR=$(pwd); fi

#
if [ -n "${SUFFIX}" ]

then for FILE in "${INPUT_DIR}"/*"${SUFFIX}"
do PREFIX=$(echo "${FILE}" | sed -r "s|$INPUT_DIR\/(.*)$SUFFIX|\1|")
echo "Using file extension option (Option 1) for file: ${FILE}"
antismash $FILE --output-dir "$PREFIX" -c "${CORES}" --asf --allow-long-headers --genefinding-tool prodigal --clusterhmmer --tigrfam --pfam2go --output-basename $PREFIX
done
Rscript "${SCRIPT_PATH}"/extract_cluster_data.R -i "${OUTPUT_DIR}" -p "${PATTERN}" -r "${RECURSIVE}"
#
else for FILE in $(echo $FILES | sed "s/,/ /g")
do FILE=$(echo "${INPUT_DIR}"/"${FILE}")
PREFIX=$(echo "${FILE}" | sed -r "s|.*\/+(.*)|\1|")
echo "Using file name option (Option 2) for file: ${FILE}"
antismash $FILE --output-dir "$PREFIX" -c "${CORES}" --asf --allow-long-headers --genefinding-tool prodigal --clusterhmmer --tigrfam --pfam2go --output-basename $PREFIX
done
Rscript "${SCRIPT_PATH}"/extract_cluster_data.R -i "${OUTPUT_DIR}" -p "${PATTERN}" -r "${RECURSIVE}"
fi

