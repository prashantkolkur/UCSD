working_folder=/oasis/scratch/comet/pkolkur/temp_project/python_training_3d
data_folder=/oasis/scratch/comet/pkolkur/temp_project/python_training_data

trainingimages=/oasis/scratch/comet/t1singha/temp_project/TrainingImages_Mitos_1_80/training_images/
traininglabels=/oasis/scratch/comet/t1singha/temp_project/TrainingImages_Mitos_1_80/training_labels/
trainingdata="$data_folder"/training_processed_data

validationimages=/oasis/scratch/comet/t1singha/temp_project/TrainingImages_Mitos_1_80/validation_images
validationlabels=/oasis/scratch/comet/t1singha/temp_project/TrainingImages_Mitos_1_80/validation_labels
validationdata="$data_folder"/validation_processed_data

trained_network="$working_folder"/trained_net

#trainted_net=/oasis/scratch/comet/aborch/temp_project/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out
#img_folder=/oasis/scratch/comet/aborch/temp_project/mito_testsample/testset
#trainted_net=/oasis/scratch/comet/mmadany/temp_project/Keun/msog_perf_sixset8kadd_trnet
#img_folder=/oasis/scratch/comet/mmadany/temp_project/Keun/CDeep3M-BatchJob-7Hnfq9gUomgr7EIqcLL56ZUHtuyj7TXG/Partition-2
#out_folder="$working_folder"/big_images_prediction_5_15_p100_gpu_4_cpu_28_w_script_partition_2

cd $working_folder
#cd $data_folder
#runprediction.sh --augspeed 1 $trainted_net $img_folder $out_folder
#python3 /home/pkolkur/python_training/PreprocessTrainingData.py $trainingimages $traininglabels $trainingdata
#python3 /home/pkolkur/python_training/PreprocessValidation_new.py $validationimages $validationlabels $validationdata
#runtraining.sh --validation_dir $validationdata --numiterations 50000 $trainingdata $trained_network
python3 /home/pkolkur/python_training/run_python_training_3D.py --training_data $trainingdata --validation_data $validationdata --batch_size 32 --nOfItr 50000 >> log_file




