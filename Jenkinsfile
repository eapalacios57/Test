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
            
            post {
                success {
                    println "Stage Stop App <<<<<< success >>>>>>"
                    script{
                        statusCode='success';
                    }
                }
                unstable {
                    println "Stage Stop App <<<<<< unstable >>>>>>"    
                    script{
                        statusCode='unstable';
                    }              
                }
                failure {
                    println "Stage Stop App <<<<<< failure >>>>>>"
                    script{
                        statusCode='failure';
                    }
                }
           }
        }

        stage('Undeploy'){
           agent {
                label 'master' 
           }
           when { anyOf { branch 'devops'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps{
               //Manejo del status code de este stage
                catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                    script{                          
                       echo "Estatus Code Stage Anterior(Stop App): ${statusCode}";
                       if( statusCode == 'success' ){
                        sshCommand remote: remote, command: "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl $urlWlBirc -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -undeploy -name ${artifactNameWlBirc} -targets ${clusterWlBirc} -usenonexclusivelock -graceful -ignoresessions"
                        /*
                          sh """
                              #Detener la aplicacion con el nombre del artefacto
                              ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl $urlWlBirc -username ${userwlBirc} -password $passwlBirc -undeploy -name ${artifactNameWlBirc} -targets ${clusterWlBirc} -usenonexclusivelock -graceful -ignoresessions"
                          """
                        */
                       }
                       if( statusCode == 'failure' || statusCode == 'unstable' ){
                            autoCancelled = true
                            error('Aborting the build.')
                       }
                        }
                    }
                }
            post {
               success {
                   println "Stage Undeploy <<<<<< success >>>>>>"
                   script{
                        statusCode='success';
                    echo "Copy ear to Server Web Logic";
                    sshPut remote: remote, from: "Despliegue/${artifactNameWlBirc}.${extension}", into: "${pathwlBirc}/DeploysTemp/${BRANCH_NAME}"

                   /*
                   withCredentials([
                        file(
                            credentialsId: "${idKeyWlSshBirc}",
                            variable: 'KeyWlSshBirc')
                        ]){
                        echo "Copy ear to Server Web Logic";
                        sh """
                            #Copiar el artefacto hacia el servidor weblogic.
                            scp -i ${KeyWlSshBirc} -P ${puertoWlSshBirc} Despliegue/${artifactNameWlBirc}.${extension} oracle@${serverWlSshBirc}:${pathwlBirc}/DeploysTemp/${BRANCH_NAME}
                        """*/
                    
                   }
                  }
               unstable {
                   script{
                        statusCode='unstable';
                   } 
                   println "Stage Undeploy <<<<<< unstable >>>>>>"
               }
               failure {
                    println "Stage Undeploy <<<<<< failure >>>>>>"
                    //withCredentials([file(credentialsId: "${idKeyWlSshBirc}",variable: 'KeyWlSshBirc')]){    
                        script{
                            if( statusCode == 'success' ){
                                echo "Start App";
                                sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWlBirc}"
                                /*
                                sh """
                                    #Inicializa la aplicación como estaba en el stage anterior
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${userwlBirc} -password ${passwlBirc} -start -name ${artifactNameWlBirc}"
                                """*/
                            }                           
                            statusCode='failure';
                        }
                    }
               }              
            }                    
        }            
    }    
    


