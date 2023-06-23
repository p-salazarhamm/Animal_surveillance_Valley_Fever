### 1. Merge Illumina paired end reads with [USEARCH](https://doi.org/10.1093/bioinformatics/btq461)
```
#max 10% or 20 bp different in overlapped region
#minimum merge length of 200 bp because many had staggered pairs

#OLD VERSION: ./usearch9 -fastq_mergepairs sample_R1.fastq sample_R2.fastq -fastqout sample_merged.fq -fastq_minmergelen 200 -fastq_maxdiffs 20 -fastq_maxdiffpct 10 -report sample_merge_report.txt -tabbedout sample_merged_tabbedout.txt

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
### 2b. Alternatively strip primers in USEARCH
```
#ITS3F primer GCATCGATGAAGAACGCAGC length 20 (White et al. 1990)
#ITS4R primer TCCTCCGCTTATTGATATGC length 20 (White et al. 1990)

./usearch11 -fastx_truncate merged.fq -stripleft 20 -stripright 20 -fastqout stripped.fq
```
### 3. Fastq filter in USEARCH
#maximum expected error threshold 1.0
#min length of sequence 150
```
./usearch11 -fastq_filter stripped.fq -fastaout filt.fa -fastq_maxee 1 -fastq_minlen 150
```
### 4. Global trimming in USEARCH
```
./usearch11 -fastx_truncate filt.fa -trunclen 250 -fastaout trim.fa
```
### 5. Dereplication in USEARCH
```
./usearch11 -fastx_uniques filt.fa -sizeout -fastaout uniques.fa
```
### 6a. Cluster into operational taxonomic units (OTUs) at 99% identity with [UPARSE](https://doi.org/10.1038/nmeth.2604)
```
cat *_uniques.fa > all_uniques.fa

./usearch11 -cluster_otus all_uniques.fa -otus uparse_otus.fa -relabel OTU
./usearch11 -usearch_global all_uniques.fa -db uparse_otus.fa -strand both -id 0.99 -otutabout otu_tab.txt -biomout otu_biom.biom
```
### 6b. Cluster into zero-radius operational taxonomic units (zOTUs) with [UNOISE](https://doi.org/10.1101/081257)
```
./usearch11 -unoise3 all_uniques.fa -zotus unoise_zotus.fasta -tabbedout unoise_tab.txt

./usearch11 -fastx_relabel unoise_zotus.fasta -prefix zOTU -fastaout unoise_zotus_relabeled.fasta -keep_annots

./usearch11 -otutab all_uniques.fa -zotus unoise_zotus_relabeled.fasta -otutabout unoise_otu_tab.txt -biomout unoise_otu_biom.biom -mapout unoise_map.txt -notmatched unoise_notmatched.fasta -dbmatched dbmatches.fasta -sizeout
```
### 6. Assign taxonomy with [sintax](https://doi.org/10.1101/074161) and UNITE database 
```
#OLD VERSION: ./usearch9 -sintax otus.fa -db utax_reference_dataset_all_04.02.2020_corrected.fasta -tabbedout otus.sintax -strand both -sintax_cutoff 0.8

./usearch11 -sintax otus.fa -db XXXX -tabbedout otus.sintax -strand both -sintax_cutoff 0.8
```
