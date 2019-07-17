import numpy as np

def augment_data(img_in, lbl_in, i=0):
    print ('\nCreate variation {0} and {1}'.format(str(i), str(i+8)))
    augment_choices = {
            0: (img_in, lbl_in), 
            1: (np.flip(img_in, 1), np.flip(lbl_in, 1)),
            2: (np.flip(img_in, 2), np.flip(lbl_in, 2)),
            3: (np.rot90(img_in,  1, (1, 2)), np.rot90(lbl_in,  1, (1, 2))),
            4: (np.rot90(img_in, -1, (1, 2)), np.rot90(lbl_in, -1, (1, 2))),
            5: (np.rot90(np.flip(img_in, 1), 1, (1, 2)), np.rot90(np.flip(lbl_in, 1), 1, (1, 2))),
            6: (np.rot90(np.flip(img_in, 2), 1, (1, 2)), np.rot90(np.flip(lbl_in, 2), 1, (1, 2))),
            7: (np.rot90(img_in, 2, (1, 2)), np.rot90(lbl_in, 2, (1, 2)))
        }
    (img_out, lb_out) = augment_choices.get(i, (img_in, lbl_in))

    return img_out, lb_out

