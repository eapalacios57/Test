def remote = [:]
remote.name = 'birc'
remote.host = "190.85.106.202"
remote.port = 2224
remote.allowAnyHosts = true
pipeline {
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
    }
    environment {
        WEBLOGIC_CREDENTIAL = credentials('UserandpasswordConsole')
        
    }  
    stages {
        stage("Build") {
            agent any
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            steps {
                echo "build Pendiente Definición"
              
            }
        }
        //Setea las variables almacenas en el arhivo .JSON
        
        stage('Set variables'){
            agent {
                label 'master' 
            }
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            steps{
                script{
                    
                   JENKINS_FILE = readJSON file: 'Jenkinsfile.json';
                   urlWlBirc  = JENKINS_FILE[BRANCH_NAME]['urlWlBirc'];
                   idUserANDPassWlBirc = JENKINS_FILE[BRANCH_NAME]['idUserANDPassWlBirc'];
                   artifactNameWlBirc = JENKINS_FILE[BRANCH_NAME]['artifactNameWlBirc'];
                   domainWlBirc = JENKINS_FILE[BRANCH_NAME]['domainWlBirc'];
                   pathwlBirc = JENKINS_FILE[BRANCH_NAME]['pathwlBirc'];
                   clusterWlBirc = JENKINS_FILE[BRANCH_NAME]['clusterWlBirc'];
                   serverWlSshBirc = JENKINS_FILE[BRANCH_NAME]['serverWlSshBirc'];
                   puertoWlSshBirc = JENKINS_FILE[BRANCH_NAME]['puertoWlSshBirc'];
                   idKeyWlSshBirc = JENKINS_FILE[BRANCH_NAME]['idKeyWlSshBirc'];
                   extension = JENKINS_FILE[BRANCH_NAME]['extension'];
                   
                }
            }
        }
        stage('Stop App'){
             agent {
                label 'master' 
            }
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } } 
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'ssh_server_weblogic', passwordVariable: 'password', usernameVariable: 'userName')]) {
                    remote.user = userName
                    remote.password = password
                    } 
                    
                    //sshCommand remote: remote, command: 'cd /u01/oracle/user_projects/domains/base_domain/bin && . ./setDomainEnv.sh ENV && java weblogic.Deployer -debug -remote -verbose -adminurl t3://172.17.0.3:9005 -username weblogic -password Bolivar2021* -stop -name FACTURAELECTRONICA'
                    echo "${WEBLOGIC_CREDENTIAL_USR}"
                    sshCommand remote: remote, command: "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -stop -name $artifactNameWlBirc"
                    sshCommand remote: remote, command: 'ls -la'
                    }
                   }

            }
        }
    }
}
