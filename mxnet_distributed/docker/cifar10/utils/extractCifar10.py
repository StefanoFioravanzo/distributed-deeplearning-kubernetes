# Load and extract 10 images from the first batch of the CIFAR10 dataset

import cv2
import pickle
import numpy as np
from pathlib import Path

import mxnet as mx

DATASET_PATH = Path.home() / "Work" / "Datasets"
CIFAR_10 = DATASET_PATH / "cifar-10-batches-py"

def extractImagesAndLabels(path, file):
    f = open(path / file, 'rb')
    data = pickle.load(f, encoding='bytes')
    images = data[b'data']
    images = np.reshape(images, (10000, 3, 32, 32))
    labels = data[b'labels']
    imagearray = mx.nd.array(images)
    labelarray = mx.nd.array(labels)
    return imagearray, labelarray

def extractCategories(path, file):
    f = open(path / file, 'rb')
    data = pickle.load(f, encoding='bytes')
    return data[b'label_names']

def saveCifarImage(array, path, file):
    # array is 3x32x32. cv2 needs 32x32x3
    v = array.asnumpy().transpose(1,2,0)
    # array is RGB. cv2 needs BGR
    v = cv2.cvtColor(v, cv2.COLOR_RGB2BGR)
    # save to PNG file
    return cv2.imwrite(str(path / (file + ".png")), v)


if __name__ == "__main__":
    imgarray, lblarray = extractImagesAndLabels(CIFAR_10, "data_batch_1")
    print(imgarray.shape)
    print(lblarray.shape)

    categories = extractCategories(CIFAR_10, "batches.meta")

    imgs = []
    for i in range(0,10):
        saveCifarImage(imgarray[i], Path.cwd() / "cifar10", "image{}".format(i))
        category = lblarray[i].asnumpy()
        category = (int)(category[0])
        imgs.append(categories[category])
    print(imgs)
