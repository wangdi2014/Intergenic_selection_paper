#!/usr/bin/bash

species=$1
analysis=$2
base_dir=$3

species_analysis="$species""_""$analysis"

rm -r "./$species_analysis/"

mkdir "./$species_analysis/"

perl "Simulator.pl" "$species" "$analysis" "$base_dir"

# Calculate dN/dS
mkdir "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp"

cd "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp"

cp "$base_dir/Analysis/$analysis/yn00.ctl" "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp"

cp "$base_dir/Analysis/$analysis/$species_analysis/${species}_core_gene_alignment_simulated.fasta" "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp"

mv "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp/${species}_core_gene_alignment_simulated.fasta" "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp/ali.fasta"

yn00 yn00.ctl

cd "$base_dir/Analysis/$analysis"

perl "dnds_parser.pl" "$species" "$analysis" "$base_dir"

#rm -r "$base_dir/Analysis/$analysis/$species_analysis/dnds_tmp"

# Calculate dI
perl "Alignment_splitter_intergenic_annotation_files.pl" "$species" "$analysis" "$base_dir"

gcc Pairwise_SNP_caller_intergenic_annotation.c -o Pairwise_SNP_caller_intergenic_annotation -lm

category_array=("Promoter" "Terminator" "Non_coding_RNA" "Unannotated")
category_file_array=("promoter" "terminator" "non_coding_RNA" "unannotated")

category_count=${#category_array[@]}

for ((i=0; i < $category_count ; i++)); do
	
	./Pairwise_SNP_caller_intergenic_annotation "$species" "$analysis" "$base_dir" "${category_array[$i]}" "${category_file_array[$i]}"
done

# Combine dN/dS and dI
perl "dnds_dids_combiner.pl" "$species" "$analysis" "$base_dir"

