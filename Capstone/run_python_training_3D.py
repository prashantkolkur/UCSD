from generator import get_training_generators
import h5py
import argparse
import tables
from keras.utils.io_utils import HDF5Matrix
import os
import sys
from keras.callbacks import ModelCheckpoint
from keras.optimizers import Adam
from MultiResUnet3D import MultiResUnet3D
from keras.utils import multi_gpu_model
from keras.models import Sequential, load_model
#from keras import backend as K
#print (K.backend())
from tensorflow.python.client import device_lib

def get_available_gpus():
    local_device_protos = device_lib.list_local_devices()
    return [x.name for x in local_device_protos if x.device_type == 'GPU']

print ("GPU's: ",get_available_gpus())

parser = argparse.ArgumentParser(description='Running Model Training')
parser.add_argument('--training_data', type=str, required=True)
parser.add_argument('--validation_data', type=str, required=True)
parser.add_argument('--batch_size', type=int, default=16)
parser.add_argument('--nOfItr', type=int, default=100)
parser.add_argument('--lr', type=float, default=0.001)

parsed_data = parser.parse_args(sys.argv[1:])

lr = parsed_data.lr
batch_size = parsed_data.batch_size
numberOfIterations = parsed_data.nOfItr

model = MultiResUnet3D(3, 256, 256, 1)
#model = load_model("multiresunet_membrane.h5")
model = multi_gpu_model(model, gpus=4)
opt = Adam(lr=0.001, decay=1e-6)
model.compile(loss='binary_crossentropy', optimizer=opt, metrics = ['accuracy'])

model_checkpoint = ModelCheckpoint('multiresunet_membrane.h5', monitor='loss', verbose=1, save_best_only=True)

print("Training is starting")

h5_folder = parsed_data.training_data
all_h5_files = [file_name for file_name in os.listdir(h5_folder) if file_name.endswith('h5')]

for file_name in all_h5_files:
	print ("Training started on File: ", file_name)
	data_file_opened = tables.open_file(os.path.join(h5_folder, file_name), "r")
	train_generator, steps_per_epoch = get_training_generators(data_file_opened,
                                                  		   batch_size=batch_size,
                                                  		   patch_shape=(3, 256, 256, 1)
                                                 		  )
	model.fit_generator(train_generator, steps_per_epoch=steps_per_epoch, 
			    epochs=int(numberOfIterations/len(all_h5_files)), callbacks=[model_checkpoint])
	print ("Training completed on File: ", file_name)

print ("Hurry!! Training Completed")

