# PreprocessValidation
# Makes hdf5 validation file from raw images and corresponding labels 
#
# Syntax : PreprocessValidation ~/validation/images/ ~/validation/labels/ ~/validation/combined
#
#
#----------------------------------------------------------------------------------------
## PreprocessTraining for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 04/2018
#----------------------------------------------------------------------------------------
#
# Runtime: <1 min
#


# ----------------------------------------------------------------------------------------
## Initialize
# ----------------------------------------------------------------------------------------
import os
import sys
import time
from imageimporter import imageimporter
from checkpoint_nobinary import checkpoint_nobinary
from checkpoint_isbinary import checkpoint_isbinary
import h5py
import numpy as np

print('Starting Validation data Preprocessing')

arg_list = sys.argv[1:]

if len(arg_list) < 3:
    print ('Use -> python PreprocessValidation.py /validation/images/ /validation/labels/ /validdation/combined')
    exit()

tic = time.time()

trainig_img_path = arg_list[0]
print('Validation Image Path:', trainig_img_path) 
label_img_path = arg_list[1]
print('Validation Label Path:', label_img_path)
outdir = arg_list[2]
print('Output Path:', outdir)

# ----------------------------------------------------------------------------------------
## Load images
# ----------------------------------------------------------------------------------------

print('Loading:')
print(trainig_img_path)
imgstack = imageimporter(trainig_img_path)
print('Verifying images')
checkpoint_nobinary(imgstack)

# ----------------------------------------------------------------------------------------
## Load labels
# ----------------------------------------------------------------------------------------

print('Loading:')
print(label_img_path)
lblstack = imageimporter(label_img_path)
print('Verifying labels')
checkpoint_isbinary(lblstack)

# ----------------------------------------------------------------------------------------
## Convert and save
# ----------------------------------------------------------------------------------------

img = imgstack.astype('float32')
lb = lblstack.astype('float32')

img = np.array([img[n, i*256:(i+1)*256, j*256:(j+1)*256, :] for j in range(4) for i in range(4) for n in range(img.shape[0])])
lb = np.array([lb[n, i*256:(i+1)*256, j*256:(j+1)*256, :] for j in range(4) for i in range(4) for n in range(lb.shape[0])])
print(img.shape)
print(lb.shape)

d_details = '/data'
l_details = '/label'

if not os.path.isdir(outdir):
    os.mkdir(outdir)

ext = ".h5"

filename = os.path.abspath(outdir)+'/'+'validation_stack_v{0}{1}'.format(str(1), ext)
print ('Saving: ', filename)
hdf5_file = h5py.File(filename, mode='w')
hdf5_file.create_dataset(d_details, data=img)
hdf5_file.create_dataset(l_details, data=lb)
hdf5_file.close()

# ----------------------------------------------------------------------------------------
## Completed
# ----------------------------------------------------------------------------------------

print('Validation data stored in %06d seconds.\n'% (np.round(time.time()-tic)))

