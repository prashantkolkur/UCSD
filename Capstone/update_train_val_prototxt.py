## Usage update_train_val_prototxt(outdir, model, train_file, valid_file)
##
## Updates <outdir>/<model>/train_val.prototxt file
## replacing lines with 'train_file.txt' with value of train_file parameter
## like so:
## data_source: "train_file"
## and replacing lines with 'valid_file.txt' with value of valid_file parameter
## like so:
## data_source: "valid_file"
##

def update_train_val_prototxt(outdir,model,train_file,valid_file):
  train_val_prototxt = outdir + '/' + model + '/' + 'train_val.prototxt'
  t_data_file = open(train_val_prototxt, 'r')
  t_data = t_data_file.readlines()
  train_out = open(train_val_prototxt, 'w')

  for line in t_data:
    if 'train_file.txt' in line:
      train_out.write('data_source: ' + '"' + train_file + '"\n')
    elif 'valid_file.txt' in line:
      train_out.write('data_source: ' + '"' + valid_file + '"\n')
    else:
      train_out.write(line)

  train_out.close()
  