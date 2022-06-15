#!/bin/bash

main(){
    readonly DOCKER_PATH=/usr/bin/docker
    readonly IMAGE_WITHOUT_TAG=reademption_dev
    readonly IMAGE=tillsauerwein/reademption_dev:2.0
    readonly CONTAINER_NAME=reademption_container_tutorial
    readonly READEMPTION_ANALYSIS_FOLDER=reademption_analysis
    readonly READEMPTION_INPUT_READS=${READEMPTION_ANALYSIS_FOLDER}/input/reads
    readonly READEMPTION_INPUT_HUMAN_REFERENCES=${READEMPTION_ANALYSIS_FOLDER}/input/human_reference_sequences
    readonly READEMPTION_INPUT_STAPH_REFERENCES=${READEMPTION_ANALYSIS_FOLDER}/input/staphylococcus_reference_sequences
    readonly READEMPTION_INPUT_HUMAN_ANNOTATIONS=${READEMPTION_ANALYSIS_FOLDER}/input/human_annotations
    readonly READEMPTION_INPUT_STAPH_ANNOTATIONS=${READEMPTION_ANALYSIS_FOLDER}/input/staphylococcus_annotations
    readonly FTP_SOURCE=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/210/855/GCF_000210855.2_ASM21085v2
    readonly MAPPING_PROCESSES=24
    readonly COVERAGE_PROCESSES=24
    readonly GENE_QUANTI_PROCESSES=24
    readonly LOCAL_OUTOUT_PATH="."
    readonly READS_SUBSETS_FOLDER=data/reads_subsets


    if [ ${#@} -eq 0 ]
    then
        echo "Specify function to call or 'all' for running all functions"
        echo "Avaible functions are: "
        grep "(){" run.sh | grep -v "^all()" |  grep -v "^main(){" |  grep -v "^#"  | grep -v 'grep "(){"' | sed "s/(){//"
    else
        "$@"
    fi
}

all(){
    ## Creating image and container:
    ##build_reademption_image_no_cache
    #build_reademption_image
    #create_running_container
    ## Running the analysis
    #create_reademption_folder
    #download_staphylococcus_genome
    #download_staphylococcus_annotation
    #download_human_genome
    #download_human_annotation
    #download_reads

    ## Running the analysis:
    align
    quanti
    



    #build_coverage_files
    #run_gene_quanti
    #run_deseq
    #copy_analysis_to_local


    ## inspecting the container:
    #execute_command_ls
    #execute_command_tree
    #show_containers
    #stop_container
    #start_container
    #remove_all_containers

}

## Running analysis

build_reademption_image(){
    $DOCKER_PATH build -f Dockerfile -t $IMAGE .
}

# creates a running container with bash
create_running_container(){
    $DOCKER_PATH run --name $CONTAINER_NAME -it -d $IMAGE bash
}


# create the reademption input and outputfolders inside the container
create_reademption_folder(){
    $DOCKER_PATH exec $CONTAINER_NAME \
        reademption create --project_path ${READEMPTION_ANALYSIS_FOLDER} \
	--species \
	human="Homo sapiens" \
	staphylococcus="Staphylococcus aureus"
}

#####################
download_staphylococcus_genome(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 wget -O ${READEMPTION_INPUT_STAPH_REFERENCES}/staphylococcus_genome.fa.gz \
		 ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz

    $DOCKER_PATH exec $CONTAINER_NAME \
		 gunzip ${READEMPTION_INPUT_STAPH_REFERENCES}/staphylococcus_genome.fa.gz
}




download_staphylococcus_annotation(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 wget -O ${READEMPTION_INPUT_STAPH_ANNOTATIONS}/staphylococcus_annotation.gff.gz \
		 ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz
    $DOCKER_PATH exec $CONTAINER_NAME \
		 gunzip ${READEMPTION_INPUT_STAPH_ANNOTATIONS}/staphylococcus_annotation.gff.gz
}

 
download_human_genome(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 wget -O ${READEMPTION_INPUT_HUMAN_REFERENCES}/human_genome.fa.gz \
		 ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/GRCh38.p10.genome.fa.gz
    $DOCKER_PATH exec $CONTAINER_NAME \
		 gunzip ${READEMPTION_INPUT_HUMAN_REFERENCES}/human_genome.fa.gz
}


download_human_annotation(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 wget -O ${READEMPTION_INPUT_HUMAN_ANNOTATIONS}/human_annotation.gff.gz \
		 ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/gencode.v27.annotation.gff3.gz
    $DOCKER_PATH exec $CONTAINER_NAME \
		 gunzip ${READEMPTION_INPUT_HUMAN_ANNOTATIONS}/human_annotation.gff.gz
}

download_reads(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 wget https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Infected_replicate_1.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Infected_replicate_2.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Infected_replicate_3.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Steady_state_replicate_1.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Steady_state_replicate_2.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Steady_state_replicate_3.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Uninfected_replicate_1.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Uninfected_replicate_2.fq \
		 https://raw.githubusercontent.com/Tillsa/Tillsa-2022-06-15-READemption_tutorial_data/main/Uninfected_replicate_3.fq \
		 -P ${READEMPTION_INPUT_READS}
}


mount(){
    mkdir -p shared
    $DOCKER_PATH run -d \
      -it \
      --name $CONTAINER_NAME \
      --mount type=bind,source="$(pwd)"/shared,target=/root/shared \
      $IMAGE
}



align(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      reademption align \
      -p ${MAPPING_PROCESSES} --split -g -q --project_path ${READEMPTION_ANALYSIS_FOLDER}
}

quanti(){
    $DOCKER_PATH exec $CONTAINER_NAME \
		 reademption gene_quanti \
		 --features gene \
		 -p ${GENE_QUANTI_PROCESSES} --project_path ${READEMPTION_ANALYSIS_FOLDER}
}


# download the reference sequences to the reademption iput folder inside the container
download_reference_sequences(){
  $DOCKER_PATH exec $CONTAINER_NAME \
    wget -O ${READEMPTION_ANALYSIS_FOLDER}/input/reference_sequences/salmonella.fa.gz \
      ${FTP_SOURCE}/GCF_000210855.2_ASM21085v2_genomic.fna.gz
  $DOCKER_PATH exec $CONTAINER_NAME \
    gunzip ${READEMPTION_ANALYSIS_FOLDER}/input/reference_sequences/salmonella.fa.gz
}


download_annotation(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      wget -O ${READEMPTION_ANALYSIS_FOLDER}/input/annotations/salmonella.gff.gz \
        ${FTP_SOURCE}/GCF_000210855.2_ASM21085v2_genomic.gff.gz
    $DOCKER_PATH exec $CONTAINER_NAME \
      gunzip ${READEMPTION_ANALYSIS_FOLDER}/input/annotations/salmonella.gff.gz
}

download_and_subsample_reads(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R1.fa.bz2
    $DOCKER_PATH exec $CONTAINER_NAME \
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R2.fa.bz2
    $DOCKER_PATH exec $CONTAINER_NAME \
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/LSP_R1.fa.bz2
    $DOCKER_PATH exec $CONTAINER_NAME \
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/LSP_R2.fa.bz2
}

align_reads(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      reademption align \
			-p ${MAPPING_PROCESSES} \
			-a 95 \
			-l 20 \
			--poly_a_clipping \
			--progress \
			--split \
			     -f $READEMPTION_ANALYSIS_FOLDER

}

build_coverage_files(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      reademption coverage \
      -p $COVERAGE_PROCESSES \
      -f $READEMPTION_ANALYSIS_FOLDER

    echo "coverage done"
}

run_gene_quanti(){
    $DOCKER_PATH exec $CONTAINER_NAME \
      reademption gene_quanti \
      -p $GENE_QUANTI_PROCESSES \
         -f $READEMPTION_ANALYSIS_FOLDER
    echo "gene quanti done"
}



run_deseq(){
    $DOCKER_PATH exec $CONTAINER_NAME \
			reademption deseq \
			--libs InSPI2_R1,InSPI2_R2,LSP_R1,LSP_R2 \
			--conditions replicate1,replicate2,replicate1,replicate2 \
         -f $READEMPTION_ANALYSIS_FOLDER
    echo "deseq done"
}

copy_analysis_to_local(){
  $DOCKER_PATH cp ${CONTAINER_NAME}:/root/${READEMPTION_ANALYSIS_FOLDER} ${LOCAL_OUTOUT_PATH}
}

## Inspecting

# execute a command and keep the container running
# only works when container is running
build_reademption_image_no_cache(){
    $DOCKER_PATH build --no-cache -f Dockerfile -t $IMAGE .
}


execute_command_ls(){
    $DOCKER_PATH exec $CONTAINER_NAME ls
}

show_reademption_version(){
    $DOCKER_PATH exec $CONTAINER_NAME reademption --version
}

# execute a command and keep the container running
# only works when container is running
execute_command_tree(){
    $DOCKER_PATH exec $CONTAINER_NAME tree $READEMPTION_ANALYSIS_FOLDER
}


show_containers(){
   $DOCKER_PATH ps -a
}

# stop the container
stop_container(){
    $DOCKER_PATH stop $CONTAINER_NAME
}

# start container and keep it runnning
start_container(){
    $DOCKER_PATH start $CONTAINER_NAME
}

interactive_bash(){
    $DOCKER_PATH run -it $IMAGE
}

attach(){
    $DOCKER_PATH exec -it $CONTAINER_NAME bash
}

remove_all_containers(){
    $DOCKER_PATH container prune
}

prune(){
    $DOCKER_PATH system prune -a --volumes
}
main $@
