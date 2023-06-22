### 1.Merge Illumina paired end reads with [USEARCH](https://doi.org/10.1093/bioinformatics/btq461)
```
#max 10% or 20 bp different in overlapped region
#minimum merge length of 200 bp because many had staggered pairs

./usearch9 -fastq_mergepairs sample_R1.fastq sample_R2.fastq -fastqout sample_merged.fq -fastq_minmergelen 200 -fastq_maxdiffs 20 -fastq_maxdiffpct 10 -report sample_merge_report.txt -tabbedout sample_merged_tabbedout.txt

./usearch11 -fastq_mergepairs sample_R1.fastq -reverse sample_R2.fastq -fastqout sample_merged.fq -fastq_minmergelen 200 -fastq_maxdiffs 20 -fastq_pctid 10 -report sample_merge_report.txt -tabbedout sample_merged_tabedbout.txt
```
### 2a. [Cutadapt](https://doi.org/10-12.10.14806/ej.17.1.200 ) to remove adapter sequences, primers, and poly-A tails
```
module load py-cutadapt2-2.5-gcc-4.8.5-python3-rc2hfb6

#Trim ITS4-FUN primer (Taylor et al. 2016)
cutadapt -g ^AGCCTCCGCTTATTGATATGCTTAART --discard-untrimmed -e 0.2 -m 200 -o trimmed.fq input.fastq

#Trim 5.8S-FUN primer (Taylor et al. 2016)
cutadapt -a AGWGATCCRTTGYYRAAAGTT$ --discard-untrimmed -e 0.2 -m 200 -o trimmed.fq input.fastq

```
### 2b. Strip primers in USEARCH

#ITS3F primer GCATCGATGAAGAACGCAGC length 20 (White et al. 1990)
#ITS4R primer TCCTCCGCTTATTGATATGC length 20 (White et al. 1990)

./usearch11 -fastx_truncate merged.fq -stripleft 20 -stripright 20 -fastqout stripped.fq

### Dereplication
```
usearch9 -fastx_uniques filtered.fa -sizeout -fastaout uniques.fa
```
### Assign trimmed reads to OTUs at 99% identity with [UPARSE](https://doi.org/10.1038/nmeth.2604), assembles the OTU table
```
usearch9 -usearch_global merged.fq -db uparse_otus.fa -strand both -id 0.99 -otutabout otu_tab.txt -biomout otu_biom.biom
```
### Assign taxonomy with [sintax](https://doi.org/10.1101/074161) and UNITE database 
```
usearch9 -sintax otus.fa -db utax_reference_dataset_all_04.02.2020_corrected.fasta -tabbedout otus.sintax -strand both -sintax_cutoff 0.8
```
