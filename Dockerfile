FROM tylern4/tensorflow-with-r

RUN pip install ipyparallel xgboost scikit-neuralnetwork tflearn \
    && ipcluster nbextension enable

COPY run_jupyter.sh /run_jupyter.sh

#rstudio
EXPOSE 8787
#jupyter
EXPOSE 8888
#tensorboard
EXPOSE 6006

CMD ["/run_jupyter.sh", "--allow-root"]

ENTRYPOINT ["/bin/bash"]
