# RecordIO files allow large data sets to be packed and split in multiple files,
# which can then be loaded and processed in parallel by multiple servers for distributed training
# Technical details on how data records are built: http://mxnet.incubator.apache.org/architecture/note_data_loading.html

import mxnet as mx

## Build CIFAR10 data records:
# We can use pre built data records dounloading them from:
#   wget http://data.mxnet.io/data/cifar10/cifar10_val.rec
#   wget http://data.mxnet.io/data/cifar10/cifar10_train.rec

# To load the files and build the iterators:
train_iter = mx.io.ImageRecordIter(
  path_imgrec="cifar10_train.rec", data_name="data", label_name="softmax_label",
  batch_size=batch, data_shape=(3,28,28), shuffle=True)

valid_iter = mx.io.ImageRecordIter(
  path_imgrec="cifar10_val.rec", data_name="data", label_name="softmax_label",
  batch_size=batch, data_shape=(3,28,28))

# the images have been saved at 28x28. Train has 50,000 records, Validation has 10,000 records.

# train from scratch a Resnet
epochs = 100

sym, arg_params, aux_params = mx.model.load_checkpoint("resnext-101",0)
mod = mx.mod.Module(symbol=sym, context=(mx.gpu(0), mx.gpu(1), mx.gpu(2), mx.gpu(3)))
mod.bind(data_shapes=train_iter.provide_data, label_shapes=train_iter.provide_label)
mod.set_params(arg_params, aux_params)
mod.fit(train_iter, eval_data=valid_iter,
        optimizer_params={'learning_rate':0.05, 'momentum':0.9}, num_epoch=epochs)
mod.save_checkpoint("resnext-101-001", epochs)
