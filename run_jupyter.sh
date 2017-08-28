#!/usr/bin/env bash

/usr/lib/rstudio-server/bin/rserver --server-daemonize=1 --server-app-armor-enabled=0

tensorboard --logdir=/tmp/log &

jupyter notebook --generate-config
echo "c.NotebookApp.password = 'sha1:a05afeade614:9fcd879edc9fbc6d18a16e1e862bf1bcb87f2456' " >> /root/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.notebook_dir = '/root'" >> /root/.jupyter/jupyter_notebook_config.py

jupyter notebook --allow-root "$@" 
