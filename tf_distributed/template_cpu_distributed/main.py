import argparse
import os
import sys
import ast
import json
import time

import tensorflow as tf

# Grab the TF_CONFIG environment variable
tf_config_json = os.environ.get("TF_CONFIG", "{}")
# Deserialize to a python object
tf_config = json.loads(tf_config_json)

# Grab the task assigned to this specific process from the config. job_name might be "worker" and task_id might be 1 for example
task = tf_config.get("task", {})
job_name = task["type"]
task_index = task["index"]

# Grab the cluster specification from tf_config and create a new tf.train.ClusterSpec instance with it
cluster_spec = tf_config.get("cluster", {})
cluster = tf.train.ClusterSpec(cluster_spec)

# start a server for a specific task
server = tf.train.Server(
    cluster,
    job_name=job_name,
    task_index=task_index)

# config
batch_size = 100
learning_rate = 0.0005
training_epochs = 20
logs_path = "./tmp/mnist/1"

# load mnist data set
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets('MNIST_data', one_hot=True)

if job_name == "ps":
    server.join()
    sys.exit()

# Between-graph replication
with tf.device(tf.train.replica_device_setter(
    worker_device="/job:worker/task:%d" % task_index,
    cluster=cluster)):

    # count the number of updates
    # global_step = tf.get_variable(
    #     'global_step',
    #     [],
    #     initializer=tf.constant_initializer(0),
    #     trainable=False)
    global_step = tf.train.get_or_create_global_step()
    # input images
    with tf.name_scope('input'):
      # None -> batch size can be any size, 784 -> flattened mnist image
      x = tf.placeholder(tf.float32, shape=[None, 784], name="x-input")
      # target 10 output classes
      y_ = tf.placeholder(tf.float32, shape=[None, 10], name="y-input")

    # model parameters will change during training so we use tf.Variable
    tf.set_random_seed(1)
    with tf.name_scope("weights"):
        W1 = tf.Variable(tf.random_normal([784, 100]))
        W2 = tf.Variable(tf.random_normal([100, 10]))

    # bias
    with tf.name_scope("biases"):
        b1 = tf.Variable(tf.zeros([100]))
        b2 = tf.Variable(tf.zeros([10]))

    # implement model
    with tf.name_scope("softmax"):
        # y is our prediction
        z2 = tf.add(tf.matmul(x, W1), b1)
        a2 = tf.nn.sigmoid(z2)
        z3 = tf.add(tf.matmul(a2, W2), b2)
        y = tf.nn.softmax(z3)

    # specify cost function
    with tf.name_scope('cross_entropy'):
        # this is our cost
        cross_entropy = tf.reduce_mean(
            -tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))

    # specify optimizer
    with tf.name_scope('train'):
        # optimizer is an "operation" which we can execute in a session
        grad_op = tf.train.GradientDescentOptimizer(learning_rate)
        train_op = grad_op.minimize(cross_entropy, global_step=global_step)

    with tf.name_scope('Accuracy'):
        # accuracy
        correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

    # create a summary for our cost and accuracy
    tf.summary.scalar("cost", cross_entropy)
    tf.summary.scalar("accuracy", accuracy)

    # merge all summaries into a single "operation" which we can execute in a session
    summary_op = tf.summary.merge_all()
    init_op = tf.global_variables_initializer()
    print("Variables initialized ...")

# The StopAtStepHook handles stopping after running given steps.
hooks=[tf.train.StopAtStepHook(last_step=1000000)]

# The MonitoredTrainingSession takes care of session initialization,
# restoring from a checkpoint, saving to a checkpoint, and closing when done
# or an error occurs.
with tf.train.MonitoredTrainingSession(master=server.target, is_chief=(task_index == 0), hooks=hooks) as sess:
    begin_time = time.time()
    frequency = 100
    while not sess.should_stop():
        # create log writer object (this will log on every machine)
        writer = tf.summary.FileWriter(logs_path, graph=tf.get_default_graph())

        # perform training cycles
        start_time = time.time()
        for epoch in range(training_epochs):

            # number of batches in one epoch
            batch_count = int(mnist.train.num_examples/batch_size)

            count = 0
            for i in range(batch_count):
                batch_x, batch_y = mnist.train.next_batch(batch_size)

                # perform the operations we defined earlier on batch
                _, cost, summary, step = sess.run(
                                                [train_op, cross_entropy, summary_op, global_step],
                                                feed_dict={x: batch_x, y_: batch_y})
                writer.add_summary(summary, step)

                count += 1
                if count % frequency == 0 or i+1 == batch_count:
                    elapsed_time = time.time() - start_time
                    start_time = time.time()
                    print("Step: %d," % (step+1),
                                " Epoch: %2d," % (epoch+1),
                                " Batch: %3d of %3d," % (i+1, batch_count),
                                " Cost: %.4f," % cost,
                                " AvgTime: %3.2fms" % float(elapsed_time*1000/frequency))
                    count = 0


        print("Test-Accuracy: %2.2f" % sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
        print("Total Time: %3.2fs" % float(time.time() - begin_time))
        print("Final Cost: %.4f" % cost)

print("done")
