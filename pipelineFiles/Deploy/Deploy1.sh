# Parametros
urlwl=${1};
userwl=${2};
passwl=${3};
ArtifactName=${4};
domainWl=${5};
cluster=${6};
pathwl=${7};

docker exec wl bash -c "sh /u01/oracle/user_projects/domains/base_domain/deploysJenkins/App/birc/Shell/Deploy.sh ${urlwl} ${userwl} ${passwl} ${ArtifactName} ${domainWl} ${cluster} ${pathwl}";