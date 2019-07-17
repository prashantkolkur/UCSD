import numpy as np

def compute_patch_indices(image_shape, patch_size, overlap):
    overlap = np.asarray(overlap)
    n_patches = np.ceil(image_shape / (patch_size - overlap))
    #print("n_patches: ", n_patches)
    overflow = (patch_size - overlap) * n_patches - image_shape + overlap
    start = -np.ceil(overflow/2)
    stop = image_shape + start
    step = patch_size - overlap
    #print("start =", start)
    #print("step =", step)
    #print("stop =", stop)
    return get_set_of_patch_indices(start, stop, step)


def get_set_of_patch_indices(start, stop, step):
    return np.asarray(np.mgrid[start[0]:stop[0]:step[0], start[1]:stop[1]:step[1],
                               start[2]:stop[2]:step[2], start[3]:stop[3]:step[3]].reshape(4, -1).T, dtype=np.int)


def get_patch_from_3d_data(data, patch_shape, patch_index):
    """
    Returns a patch from a numpy array.
    :param data: numpy array from which to get the patch.
    :param patch_shape: shape/size of the patch.
    :param patch_index: corner index of the patch.
    :return: numpy array take from the data with the patch shape specified.
    """
    patch_index = np.asarray(patch_index, dtype=np.int16)
    patch_shape = np.asarray(patch_shape)
    image_shape = data.shape[-4:]
    #print("patch_index = ", patch_index)
    #print("patch_shape = ", patch_shape)
    #print("image_shape = ", image_shape)
    if np.any(patch_index < 0) or np.any((patch_index + patch_shape) > image_shape):
        data, patch_index = fix_out_of_bound_patch_attempt(data, patch_shape, patch_index)
    return data[patch_index[0]:patch_index[0]+patch_shape[0], patch_index[1]:patch_index[1]+patch_shape[1],
                patch_index[2]:patch_index[2]+patch_shape[2], patch_index[3]:patch_index[3]+patch_shape[3]]


def fix_out_of_bound_patch_attempt(data, patch_shape, patch_index, ndim=4):
    """
    Pads the data and alters the patch index so that a patch will be correct.
    :param data:
    :param patch_shape:
    :param patch_index:
    :return: padded data, fixed patch index
    """
    image_shape = data.shape[-ndim:]
    pad_before = np.abs((patch_index < 0) * patch_index)
    #print("(patch_index < 0): ", (patch_index < 0))
    #print("pad_before: ", pad_before)
    pad_after = np.abs(((patch_index + patch_shape) > image_shape) * ((patch_index + patch_shape) - image_shape))
    pad_args = np.stack([pad_before, pad_after], axis=1)
    #print('pad_args: ', pad_args)
    if pad_args.shape[0] < len(data.shape):
        pad_args = [[0, 0]] * (len(data.shape) - pad_args.shape[0]) + pad_args.tolist()
    data = np.pad(data, pad_args, mode="edge")
    patch_index += pad_before
    return data, patch_index


