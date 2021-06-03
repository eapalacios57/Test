#!/bin/bash
set -x

echo "######################"
echo "*** Set variables  ***"
echo "######################"
#Definir nombre archiov .auth
ENV_FILE="$JOB_BASE_NAME";

# Definir variables
urlWlBirc=${1};
userwlBirc=${2};
passwlBirc=${3};
artifactNameWlBirc=${4};
domainWlBirc=${5};
pathwlBirc=${6};
clusterWlBirc=${7};
serverWlSshBirc=${8};
puertoWlSshBirc=${9};
KeyWlSshBirc=${10};
extension=${11};   

#Agregar llave a known_hosts en la primera conexión
ssh-keyscan -p ${puertoWlSshBirc} -H ${serverWlSshBirc} >> ~/.ssh/known_hosts;

#Enviamos variables archivo .auth al servidor
echo $urlWlBirc > /tmp/.auth-$ENV_FILE;
echo $userwlBirc >> /tmp/.auth-$ENV_FILE;
echo $passwlBirc >> /tmp/.auth-$ENV_FILE;
echo $artifactNameWlBirc >> /tmp/.auth-$ENV_FILE;
echo $domainWlBirc >> /tmp/.auth-$ENV_FILE;
echo $pathwlBirc >> /tmp/.auth-$ENV_FILE;
echo $clusterWlBirc >> /tmp/.auth-$ENV_FILE;
echo $serverWlSshBirc >> /tmp/.auth-$ENV_FILE;
echo $puertoWlSshBirc >> /tmp/.auth-$ENV_FILE;
echo $KeyWlSshBirc >> /tmp/.auth-$ENV_FILE;
echo $extension >> /tmp/.auth-$ENV_FILE;
echo $JOB_BASE_NAME >> /tmp/.auth-$ENV_FILE;
scp -i ${KeyWlSshBirc} -P ${puertoWlSshBirc} /tmp/.auth-$ENV_FILE oracle@${serverWlSshBirc}:/tmp;

#Enviar Archivos .sh a servidor weblogic
scp -i ${KeyWlSshBirc} -P ${puertoWlSshBirc} -r pipelineFiles/* oracle@${serverWlSshBirc}:${pathwlBirc}/Shell;

#Validamos las variables enviadas
echo "Validamos las variables y shell enviadas"
ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} "cat /tmp/.auth-$ENV_FILE";
ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} "ls -alth ${pathwlBirc}/Shell";