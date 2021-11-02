# antiSMASH 6.0.0 Lab

In today's lab we'll go through an antiSMASH 6.0.0 pipeline! antiSMASH is a general use tool for detecting and annotating secondary metabolite biosynthetic gene clusters in Archaeal, Bacterial, and Fungal genomes. antiSMASH has a variety of additional options in addition to detecting biosynthetic gene clusters and predicting the type of metabolite the cluster encodes. Predictions can be made about the chemical structures and motifs of the encoded secondary metabolites, and protein domains of the genes with the biosynthetic clusters can additionally be annotated.

The output will contain a variety of files, including a Genbank file corresponding to each detected biosynthetic cluster in a genome. antiSMASH also has a web portal for manually submitting jobs online, and some of the command line outputs (images, visualizations) can be viewed on a web browser.



## Clone the GitHub antismash_lab repository
This can be done by clicking the green "Code" button in the repo, and copying the SSH key to keyboard, then entering the following from the location you'd like to download to on Poseidon:
```
git clone <<paste the SSH key here!>>
```

cd into the antismash_lab directory
```
cd antismash_lab
```


## Setting up antiSMASH 6.0.0 conda environment
```
conda env create -f anti6_env_110221.yaml
```

Activate the environment once it finishes initializing
```
conda activate anti6
```


## Manually installing the antiSMASH 6.0.0 package

Almost there! We have set up a conda environment with all the required dependencies to run the pipeline. Now we just need to install the actual antiSMASH package, and download the databases that it uses.

Unzip the antiSMASH package
```
tar -zxf antismash-6.0.0.tar.gz
```

Install antiSMASH package (note: make sure the anti6 conda environment is activated first)
```
pip install ./antismash-6.0.0
```

Download databases used in the antiSMASH pipeline
```
download-antismash-databases
```

From the antismash_lab directory, copy and paste all the following lines and then press enter:
```
cp scripts/antismash_slurm_template.sh scripts/antismash_slurm_110221.sh
```

```
for DIR in {mags,scripts,example_output}; do CHANGE=$(realpath $DIR); sed "s|$DIR|$CHANGE|" scripts/antismash_slurm_110221.sh > scripts/tmp.sh && mv -f scripts/tmp.sh scripts/antismash_slurm_110221.sh; done
```


### Nice work! We'll submit the antiSMASH pipeline to slurm in class!

