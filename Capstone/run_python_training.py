import h5py
import os
import sys
import argparse
from keras.preprocessing.image import ImageDataGenerator
from keras.utils.io_utils import HDF5Matrix
from keras.callbacks import ModelCheckpoint
from keras.optimizers import Adam
from MultiResUnet import MultiResUnet
from keras.utils import multi_gpu_model
from keras.models import Sequential, load_model
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

model = MultiResUnet(256, 256, 1)
model = multi_gpu_model(model, gpus=4)
opt = Adam(lr=lr, decay=1e-6)
#multiresunet_model.compile(optimizer=sgd, loss = 'binary_crossentropy', metrics = ['accuracy'])
model.compile(loss='binary_crossentropy', optimizer=opt, metrics = ['accuracy'])

model_checkpoint = ModelCheckpoint('multiresunet_membrane.h5', monitor='loss', verbose=1, save_best_only=True)

image_datagen = ImageDataGenerator()
#mask_datagen = ImageDataGenerator()
#val_image_datagen = ImageDataGenerator()
#val_mask_datagen = ImageDataGenerator()

print("Training is starting")

X_val = HDF5Matrix(os.path.join(parsed_data.validation_data, "validation_stack_v1.h5"), 'data')
y_val = HDF5Matrix(os.path.join(parsed_data.validation_data, "validation_stack_v1.h5"), 'label')

val_image_generator = val_image_datagen.flow(X_val, None)
val_mask_generator = val_mask_datagen.flow(y_val, None)

# combine generators into one which yields image and masks
val_generator = zip(val_image_generator, val_mask_generator)

h5_folder = parsed_data.training_data

all_h5_files = [file_name for file_name in os.listdir(h5_folder) if file_name.endswith('h5')]
for file_name in all_h5_files:
        print ("Training started on File: ", file_name)
        
	X_train = HDF5Matrix(os.path.join(h5_folder, file_name), 'data')
	y_train = HDF5Matrix(os.path.join(h5_folder, file_name), 'label')

	train_generator = image_datagen.flow(X_train, y_train, shuffle=False)
  
	model.fit_generator(train_generator, steps_per_epoch=batch_size, epochs=int(numberOfIterations/len(all_h5_files)), callbacks=[model_checkpoint])
	#model.fit_generator(train_generator, steps_per_epoch=batch_size, epochs=numberOfIterations, callbacks=[model_checkpoint], validation_data=val_generator, validation_steps=320)
        print ("Training completed on File: ", file_name)

print ("Hurry!! Training Completed")

