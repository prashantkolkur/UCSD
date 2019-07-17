import os
import numpy as np

from patches import compute_patch_indices, get_patch_from_3d_data

def get_training_generators(data_file, batch_size, patch_shape, patch_overlap=(0, 0, 0, 0)):
    """
    Creates the training and validation generators that can be used when training the model.
    :param skip_blank: If True, any blank (all-zero) label images/patches will be skipped by the data generator.
    :param validation_batch_size: Batch size for the validation data.
    :param training_patch_start_offset: Tuple of length 3 containing integer values. Training data will randomly be
    offset by a number of pixels between (0, 0, 0) and the given tuple. (default is None)
    :param validation_patch_overlap: Number of pixels/voxels that will be overlapped in the validation data. (requires
    patch_shape to not be None)
    :param patch_shape: Shape of the data to return with the generator. If None, the whole image will be returned.
    (default is None)
    :param augment_flip: if True and augment is True, then the data will be randomly flipped along the x, y and z axis
    :param augment_distortion_factor: if augment is True, this determines the standard deviation from the original
    that the data will be distorted (in a stretching or shrinking fashion). Set to None, False, or 0 to prevent the
    augmentation from distorting the data in this way.
    :param augment: If True, training data will be distorted on the fly so as to avoid over-fitting.
    :param labels: List or tuple containing the ordered label values in the image files. The length of the list or tuple
    should be equal to the n_labels value.
    Example: (10, 25, 50)
    The data generator would then return binary truth arrays representing the labels 10, 25, and 30 in that order.
    :param data_file: hdf5 file to load the data from.
    :param batch_size: Size of the batches that the training generator will provide.
    :param n_labels: Number of binary labels.
    :param training_keys_file: Pickle file where the index locations of the training data will be stored.
    :param validation_keys_file: Pickle file where the index locations of the validation data will be stored.
    :param data_split: How the training and validation data will be split. 0 means all the data will be used for
    validation and none of it will be used for training. 1 means that all the data will be used for training and none
    will be used for validation. Default is 0.8 or 80%.
    :param overwrite: If set to True, previous files will be overwritten. The default mode is false, so that the
    training and validation splits won't be overwritten when rerunning model training.
    :param permute: will randomly permute the data (data must be 3D cube)
    :return: Training data generator, validation data generator, number of training steps, number of validation steps
    """
    
    training_generator = data_generator(data_file,
                                        batch_size=batch_size,
                                        patch_shape=patch_shape,
                                        patch_overlap=patch_overlap)

    # Set the number of training and testing samples per epoch correctly
    num_training_steps = get_number_of_steps(get_number_of_patches(data_file, patch_shape, patch_overlap=patch_overlap), 
                                             batch_size)
    print("Number of training steps: ", num_training_steps)
    
    return training_generator, num_training_steps


def get_number_of_steps(n_samples, batch_size):
    if n_samples <= batch_size:
        return n_samples
    elif np.remainder(n_samples, batch_size) == 0:
        return n_samples//batch_size
    else:
        return n_samples//batch_size + 1

def data_generator(data_file, batch_size=1, patch_shape=None, patch_overlap=(0, 0, 0, 0)):
    while True:
        x_list = list()
        y_list = list()
        index_list = create_patch_index_list(data_file.root.data.shape[-4:], patch_shape, patch_overlap)

        while len(index_list) > 0:
            index = index_list.pop()
            add_data(x_list, y_list, data_file, index, patch_shape=patch_shape)
            if len(x_list) == batch_size or (len(index_list) == 0 and len(x_list) > 0):
                yield convert_data(x_list, y_list)
                x_list = list()
                y_list = list()


def get_number_of_patches(data_file, patch_shape, patch_overlap=(0, 0, 0, 0)):
    index_list = create_patch_index_list(data_file.root.data.shape[-4:], patch_shape, patch_overlap)
    #print("index_list: ", index_list)
    count = 0
    for index in index_list:
        x_list = list()
        y_list = list()
        add_data(x_list, y_list, data_file, index, patch_shape=patch_shape)
        if len(x_list) > 0:
            count += 1
    return count


def create_patch_index_list(image_shape, patch_shape, patch_overlap):
    return list(compute_patch_indices(image_shape, patch_shape, overlap=patch_overlap))


def add_data(x_list, y_list, data_file, index, patch_shape):
    """
    Adds data from the data file to the given lists of feature and target data
    :param patch_shape: Shape of the patch to add to the data lists. If None, the whole image will be added.
    :param x_list: list of data to which data from the data_file will be appended.
    :param y_list: list of data to which the target data from the data_file will be appended.
    :param data_file: hdf5 data file.
    :param index: index of the data file from which to extract the data.
    that the data will be distorted (in a stretching or shrinking fashion). Set to None, False, or 0 to prevent the
    augmentation from distorting the data in this way.
    :return:
    """
    data, truth = get_data_from_file(data_file, index, patch_shape=patch_shape)
    #print(truth)

    x_list.append(data)
    y_list.append(truth)


def get_data_from_file(data_file, index, patch_shape):
    data, truth = data_file.root.data, data_file.root.label
    x = get_patch_from_3d_data(data, patch_shape, index)
    y = get_patch_from_3d_data(truth, patch_shape, index)
    return x, y


def convert_data(x_list, y_list):
    x = np.asarray(x_list)
    y = np.asarray(y_list)
    return x, y


