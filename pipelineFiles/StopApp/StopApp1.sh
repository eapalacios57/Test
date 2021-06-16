#!/bin/bash
set -x

echo "#################";
echo "*** Stop APP  ***";
echo "#################";

#ENV_FILE="$JOB_BASE_NAME";
ENV_FILE="DeployEAR";
ENV_PATH="/tmp/.auth-$ENV_FILE";

urlwl=$(sed -n '1p' $ENV_PATH);
userwl=$(sed -n '2p' $ENV_PATH);
passwl=$(sed -n '3p' $ENV_PATH);
ArtifactName=$(sed -n '4p' $ENV_PATH);
domainWl=$(sed -n '5p' $ENV_PATH);
cluster=$(sed -n '6p' $ENV_PATH);
pathwl=$(sed -n '7p' $ENV_PATH);
keySSH=$(sed -n '8p' $ENV_PATH);
serverWlSshBirc=$(sed -n '9p' $ENV_PATH);
JOB_BASE_NAME=$(sed -n '10p' $ENV_PATH);

docker exec wl bash -c "sh /u01/oracle/user_projects/domains/base_domain/deploysJenkins/App/birc/Shell/StopApp.sh ${urlwl} ${userwl} ${passwl} ${ArtifactName} ${domainWl}";