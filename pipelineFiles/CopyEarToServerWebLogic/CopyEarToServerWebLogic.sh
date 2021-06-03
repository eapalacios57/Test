#!/bin/bash
set -x

echo "#####################################"
echo "*** Copy ear to Server Web Logic  ***"
echo "#####################################"

#Variables
ENV_FILE=${1};

ENV_PATH="/tmp/.auth-$ENV_FILE";

urlWlBirc=$(sed -n '1p' $ENV_PATH);
userwlBirc=$(sed -n '2p' $ENV_PATH);
passwlBirc=$(sed -n '3p' $ENV_PATH);
artifactNameWlBirc=$(sed -n '4p' $ENV_PATH);
domainWlBirc=$(sed -n '5p' $ENV_PATH);
pathwlBirc=$(sed -n '6p' $ENV_PATH);
clusterWlBirc=$(sed -n '7p' $ENV_PATH);
serverWlSshBirc=$(sed -n '8p' $ENV_PATH);
puertoWlSshBirc=$(sed -n '9p' $ENV_PATH);
KeyWlSshBirc=$(sed -n '10p' $ENV_PATH);
extension=$(sed -n '11p' $ENV_PATH);
JOB_BASE_NAME=$(sed -n '12p' $ENV_PATH);

#Envair archivo a server Weblogic
scp -i ${KeyWlSshBirc} -P ${puertoWlSshBirc} Despliegue/${artifactNameWlBirc}.ear oracle@${serverWlSshBirc}:${pathwlBirc}/DeploysTemp