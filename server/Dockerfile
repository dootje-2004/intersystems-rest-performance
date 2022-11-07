ARG IMAGE=intersystemsdc/iris-community:2022.1.0.209.0-zpm
ARG INSTANCENAME="REST SERVER"

FROM ${IMAGE}

USER irisowner

ENV INIT_DIR=/home/irisowner
COPY ./init/* ${INIT_DIR}/
RUN iris rename IRIS ${INSTANCENAME} && export ISC_PACKAGE_INSTANCENAME=${INSTANCENAME} && ${INIT_DIR}/init.sh
