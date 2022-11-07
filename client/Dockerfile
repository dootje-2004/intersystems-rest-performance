ARG IMAGE=intersystemsdc/iris-community:2022.1.0.209.0-zpm

FROM ${IMAGE}

USER irisowner

ENV INIT_DIR=/home/irisowner
# ENV ISC_PACKAGE_INSTANCENAME=REST_CLIENT
COPY ./init/* ${INIT_DIR}/
# RUN iris rename IRIS $ISC_PACKAGE_INSTANCENAME && ${INIT_DIR}/init.sh
RUN ${INIT_DIR}/init.sh
