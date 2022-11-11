ARG IMAGE=intersystemsdc/iris-community:2022.1.0.209.0-zpm

FROM ${IMAGE}

USER irisowner

ENV INIT_DIR=/home/irisowner
COPY --chown=irisowner ./init/* ${INIT_DIR}/
RUN ${INIT_DIR}/init.sh
