#!/bin/bash
set -x

echo "#####################################"
echo "*** (Backup ear) simunar wl ssh  ***"
echo "#####################################"

ENV_FILE="$JOB_BASE_NAME";
ENV_PATH="/tmp/.auth-$ENV_FILE";

ssh -i ${keySSH} root@${serverWlSshBirc} "docker cp /tmp/.auth-${ENV_FILE} wl:/tmp/.auth-${ENV_FILE} ";
ssh -i ${keySSH} root@${serverWlSshBirc} 'docker exec wl bash -c "sh /u01/oracle/user_projects/domains/base_domain/deploysJenkins/App/birc/Shell/backupEar.sh"';