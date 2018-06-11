# Load CIFAR10 images and labels into an MXNET iterator

from pathlib import Path
import mxnet as mx
from extractCifar10 import extractImagesAndLabels

CIFAR_10 = Path.home() / "Work" / "Datasets" / "cifar-10-batches-py"
batches = ["data_batch_1", "data_batch_2", "data_batch_3", "data_batch_4", "data_batch_5"]
batch_size = 128

def buildTrainingSet(path):
    training_data = []
    training_label = []
    for f in batches:
        imgarray, lblarray = extractImagesAndLabels(path, f)
        if len(training_data) == 0:
            training_data = imgarray
            training_label = lblarray
        else:
            training_data = mx.nd.concatenate([training_data, imgarray])
            training_label = mx.nd.concatenate([training_label, lblarray])
    return training_data, training_label


if __name__ == "__main__":
    training_data, training_label = buildTrainingSet(CIFAR_10)
    train_iter = mx.io.NDArrayIter(
        data=training_data, label=training_label, batch_size=batch_size, shuffle=True)

    valid_data, valid_label = extractImagesAndLabels(CIFAR_10, "test_batch")
    valid_iter = mx.io.NDArrayIter(
        data=valid_data, label=valid_label, batch_size=batch_size, shuffle=True)

    print(training_data.shape)
    print(training_label.shape)
    print(valid_data.shape)
    print(valid_label.shape)
