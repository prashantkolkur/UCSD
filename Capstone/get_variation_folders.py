## Usage [vfolders] = get_variation_folders ( thedir )
##
## Returns list of variation folders found within thedir
## variable passed in. The vfolders is a struct following
## same layout as that returned by isdir.

## If thedir is not a directory, error() is invoked

import os
import sys
import h5py
import numpy as np

def imageimporter(thedir):
  #if not os.path.isdir(thedir):
  #  raise Exception(thedir, ' is not a directory')

  vfolders = [dir_name for dir_name in os.listdir(os.path.join(thedir)) if os.path.isdir(dir_name) and dir_name.startswith('v')]

#%!error <is not a directory> get_variation_folders('');

#%!error <is not a directory> get_variation_folders(program_invocation_name());

