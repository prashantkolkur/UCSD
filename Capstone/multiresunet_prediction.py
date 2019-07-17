
from keras.preprocessing.image import ImageDataGenerator
import h5py
from keras.utils.io_utils import HDF5Matrix
import os
from keras.optimizers import Adam
from keras.models import Sequential, load_model
from PIL import Image
import cv2

model = load_model("multiresunet_membrane.h5")

print ("model: ",model)
opt = Adam(lr=0.001, decay=1e-6)
model.compile(loss='binary_crossentropy', optimizer=opt, metrics = ['accuracy'])

image_datagen = ImageDataGenerator()

h5_folder = 'converted_h5'
for file_name in os.listdir(h5_folder):
    if file_name.endswith('h5'):
        #f = h5py.File(os.path.join(h5_folder, file_name), 'r')
        '''
	for i in range(f['data'].shape[0]):
                X_test = f['data'][i:i+1,:,:,:]
                a = model.predict(X_test)
                a = a.reshape(256,256,1)
                print(a.max())
                print(a.min())
                cv2.imwrite(str(i)+file_name+'_predicted.png', a)
        '''
	#X_test = f['data'][:,:,:,:]
        print(file_name)
        X_train = HDF5Matrix(os.path.join(h5_folder, file_name), 'data')
        print(X_train.shape)
        image_generator = image_datagen.flow(X_train, None, batch_size=320, shuffle=False, sample_weight=None, seed=None, save_to_dir=None, save_prefix='', save_format='png', subset=None) 
        predict_out = model.predict_generator(image_generator, steps=1,  max_queue_size=320, workers=1, use_multiprocessing=True, verbose=1)
        print(predict_out.shape)
        f = h5py.File(file_name+'_predicted.h5', 'w')
        f.create_dataset('data', data=predict_out)
        break
