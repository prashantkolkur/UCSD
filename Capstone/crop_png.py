"""
Crop image frame for CDeep3M


NCMIR/NBCR, UCSD -- Authors: M Haberl / C Churas -- Date: 5/2018

"""
import sys
import os
import skimage
import requests
from joblib import Parallel, delayed
from multiprocessing import Pool, TimeoutError, cpu_count
import time
from PIL import Image
Image.MAX_IMAGE_PIXELS = 10000000000000

def _get_number_of_tasks_to_run_based_on_instance_type(instancetypeurl, instancetypeurltimeout):
    """Gets instance type and returns number of parallel
       tasks to run based on that value. If none are found then
       default value of 2 is used.
    
    try:
        r = requests.get(instancetypeurl,
                         timeout=instancetypeurltimeout)
        if r.status_code is 200:
            if 'p3.2xlarge' in r.text:
                return 6
            if 'p3.8xlarge' in r.text:
                return 12
            if 'p3.16xlarge' in r.text:
                return 20
    except Exception as e:
        sys.stderr.write('Got exception checking instance type: ' +
                         str(e) + '\n')
    """
    return int(cpu_count()/2)

def crop_png(inputlistfile, outputlistfile, leftxcoord, rightxcoord, topycoord, bottomycoord,
             instancetypeurl='http://169.254.169.254/latest/meta-data/instance-type', 
             instancetypeurltimeout=1.0):

    in1 = leftxcoord
    in2 = rightxcoord
    in3 = topycoord
    in4 = bottomycoord

    sys.stdout.write(str(in1) + '\n')
    sys.stdout.write(str(in2) + '\n')
    sys.stdout.write(str(in3) + '\n')
    sys.stdout.write(str(in4) + '\n')

    file = open(inputlistfile, "r")
    lines = [line.rstrip('\n') for line in file]
    file.close()

    file = open(outputlistfile, "r")
    outfiles = [line.rstrip('\n') for line in file]
    file.close()

    def processInput(x):
        #from PIL import Image
        Image.MAX_IMAGE_PIXELS = 10000000000000

        #sys.stdout.write('Loading: ' + str(lines[x]) + '\n')
        img = skimage.io.imread(lines[x])
        cropped = img[in1:in2, in3:in4]
        #sys.stdout.write('Saving: ' + str(outfiles[x]) + '\n')
        try:
            a = time.time()
            skimage.io.imsave(outfiles[x], cropped, as_grey=True)
            print("skimage: ",time.time()-a)
        except:
            a = time.time()
            skimage.io.imsave(outfiles[x], cropped)
            print("skimage: ",time.time()-a)
        return
    niceness=os.nice(0)
    os.nice(10-niceness)
    p_tasks = _get_number_of_tasks_to_run_based_on_instance_type(instancetypeurl, instancetypeurltimeout)
    #sys.stdout.write('Running ' + str(p_tasks) + ' parallel tasks\n')
    results = Parallel(n_jobs=p_tasks)(delayed(processInput)(i) for i in range(0, len(lines)))
	
