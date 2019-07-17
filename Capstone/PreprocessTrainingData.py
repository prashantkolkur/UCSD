# PreprocessTraining
# Makes augmented hdf5 datafiles from raw and label images
#
# Syntax : PreprocessTraining /ImageData/training/images/ /ImageData/training/labels/ /ImageData/augmentedtraining/
#
#
#----------------------------------------------------------------------------------------
# PreprocessTraining for Deep3M -- NCMIR/NBCR, UCSD -- Date: 01/2019
#----------------------------------------------------------------------------------------
#
import os
import sys
from imageimporter import imageimporter
from checkpoint_nobinary import checkpoint_nobinary
from check_img_dims import check_img_dims
from augment_data import augment_data
from checkpoint_isbinary import checkpoint_isbinary
import h5py
import numpy as np


def main():
    print ('Starting Training data Preprocessing')
    arg_list = []
    for arg in sys.argv[1:]:
        arg_list.append(arg)

    if len(arg_list) != 3:
        print ('Use -> python3 PreprocessTrainingData.py /ImageData/training/images/ /ImageData/training/labels/ /ImageData/augmentedtraining/')
        return

    trainig_img_path = arg_list[0]
    print ('Training Image Path:', trainig_img_path)
    label_img_path = arg_list[1]
    print ('Training Label Path:', label_img_path)
    outdir = arg_list[2]
    print ('Output Path:', outdir)

    #----------------------------------------------------------------------------------------
    # Load training images
    #----------------------------------------------------------------------------------------

    print ('Loading:')
    print (trainig_img_path)
    imgstack = imageimporter(trainig_img_path)
    print ('Verifying images')
    checkpoint_nobinary(imgstack)

    #----------------------------------------------------------------------------------------
    # Load train data
    #----------------------------------------------------------------------------------------

    print ('Loading:')
    print (label_img_path)
    lblstack = imageimporter(label_img_path)
    print ('Verifying labels')
    checkpoint_isbinary(lblstack)

    #----------------------------------------------------------------------------------------
    # Check size of images and labels
    #----------------------------------------------------------------------------------------

    [imgstack, lblstack] = check_img_dims(imgstack, lblstack, 325)

    #----------------------------------------------------------------------------------------
    # Augment the data, generating 16 versions and save
    #----------------------------------------------------------------------------------------

    img_v1 = imgstack.astype('float32')
    lb_v1 = lblstack.astype('float32')

    d_details = '/data'
    l_details = '/label'

    if not os.path.isdir(outdir):
        os.mkdir(outdir)

    ext = ".h5"

    print ('Augmenting training data 1-8 and 9-16')
    for i in range(8):
        # v1-8
        img, lb = augment_data(img_v1, lb_v1, i)
        shape = img.shape
        temp_img = np.zeros([shape[1], shape[2], shape[0]], dtype=img.dtype)
        temp_lb = np.zeros([shape[1], shape[2], shape[0]], dtype=lb.dtype)
        for z in range(0, shape[0]):
            temp_img[:, :, z] = img[z].T
            temp_lb[:, :, z] = lb[z].T
        img = temp_img
        lb = temp_lb

        # v9-16
        inv_img = np.flip(img, 2)
        inv_lb = np.flip(lb, 2)

        filename = os.path.abspath(
            outdir)+'/'+'training_full_stacks_v{0}{1}'.format(str(i+1), ext)
        print ('Saving: ', filename)
        hdf5_file = h5py.File(filename, mode='w')
        hdf5_file.create_dataset(d_details, data=img)
        hdf5_file.create_dataset(l_details, data=lb)
        hdf5_file.close()

        filename = os.path.abspath(
            outdir)+'/'+'training_full_stacks_v{0}{1}'.format(str(i+1+8), ext)
        print ('Saving: ', filename)
        hdf5_file = h5py.File(filename, mode='w')
        hdf5_file.create_dataset(d_details, data=inv_img)
        hdf5_file.create_dataset(l_details, data=inv_lb)
        hdf5_file.close()

    print ('\n-> Training data augmentation completed')
    print ('Training data stored in ', outdir)
    print ('For training your model please run runtraining.sh ',
           outdir, '<desired output directory>\n')


if __name__ == "__main__":
    main()
