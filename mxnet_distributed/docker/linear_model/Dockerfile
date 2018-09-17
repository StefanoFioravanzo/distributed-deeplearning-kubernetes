# Cannot use pre-built image mxnet/python:1.1.0
# since it does not come with a mxnet version that supports
# distributed mode. Pip version does.
FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y python3-pip && \
    apt-get install -y vim iputils-ping

# Install mxnet with distributed mode enabled
RUN pip3 install mxnet==1.1.0

COPY main.py /app/main.py
COPY entrypoint.sh /app/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
