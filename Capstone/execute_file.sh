working_folder=/oasis/scratch/comet/pkolkur/temp_project/python_training_dump_05292019
train_valid_folder=/oasis/scratch/comet/t1singha/temp_project/python_training_dump

trainingimages=/home/t1singha/TrainingImages_Mitos_1_80/training_images
traininglabels=/home/t1singha/TrainingImages_Mitos_1_80/training_labels
trainingdata="$train_valid_folder"/training_processed_data

validationimages=/home/t1singha/TrainingImages_Mitos_1_80/validation_images
validationlabels=/home/t1singha/TrainingImages_Mitos_1_80/validation_labels
#validationdata="$train_valid_folder"/validation_processed_data
validationdata=/home/pkolkur/validation_converted

trained_network="$train_valid_folder"/trained_net

#trainted_net=/oasis/scratch/comet/aborch/temp_project/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out
#img_folder=/oasis/scratch/comet/aborch/temp_project/mito_testsample/testset
#trainted_net=/oasis/scratch/comet/mmadany/temp_project/Keun/msog_perf_sixset8kadd_trnet
#img_folder=/oasis/scratch/comet/mmadany/temp_project/Keun/CDeep3M-BatchJob-7Hnfq9gUomgr7EIqcLL56ZUHtuyj7TXG/Partition-2
#out_folder="$working_folder"/big_images_prediction_5_15_p100_gpu_4_cpu_28_w_script_partition_2

cd $working_folder
#runprediction.sh --augspeed 1 $trainted_net $img_folder $out_folder
#python3 /home/t1singha/python_training/PreprocessTrainingData_new.py $trainingimages $traininglabels $trainingdata
#python3 /home/t1singha/python_training/PreprocessValidation_new.py $validationimages $validationlabels $validationdata
#runtraining.sh --validation_dir $validationdata --numiterations 50000 $trainingdata $trained_network
python3 /home/pkolkur/python_training/run_python_training_non_generator.py --training_data $trainingdata --validation_data $validationdata --batch_size 128 --nOfItr 50000 >> log_file




