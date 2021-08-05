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
        
    }/* 
    stages {
        stage('Test'){
          when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } }
           agent {
                label 'docker'
           } 
           steps {
               sh './pipelineFiles/test/test.sh mvn test'
               stash includes: 'Back/target/', name: 'mysrc'
           }
        }
        stage('SonarQube analysis') {
           when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
           agent {
                  label 'nodejenkinsjdk11' 
                }      
           steps {
               script {
                   last_stage = env.STAGE_NAME

                    unstash 'mysrc'
                    /*sh """
                     ${SCANNERHOME}/bin/sonar-scanner -X -Dproject.settings=sonar-project.properties -Dsonar.projectVersion=0.${BUILD_NUMBER}
                    """*/
                    /*
                    
                    def SCANNERHOME = tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'                  
                   
                    unstash 'mysrc'
                    
                    if( BRANCH_NAME != 'master'){
                        branchSonar=BRANCH_NAME
                    }
                    
                    withSonarQubeEnv('SonarCloud') {
                        echo 'sonar'
                        sh "${SCANNERHOME}/bin/sonar-scanner -Dsonar.branch.name='${branchSonar}'"
                    }
                }
            }                            
        }
        stage("Quality gate") {
         
            /*steps {
                script {
                    last_stage = env.STAGE_NAME
                }
                waitForQualityGate abortPipeline: true
             }/*
            steps {
                script {
                    echo "Quality gate";
                }
             }
        }
        
        */
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
                    sshCommand remote: remote, command: "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -stop -name $artifactNameWlBirc"
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
                        script{
                            if( statusCode == 'success' ){
                                echo "Start App";
                                sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWlBirc}"
                              
                            }                           
                            statusCode='failure';
                        }
                    }
               }              
            }
            
        stage('Deploy'){      
           agent {
                label 'master' 
           }          
           when { anyOf { branch 'devops'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps{
               //Manejo del status code de este stage
               catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                           script{
                                echo "Estatus Code Stage Anterior (Undeploy): ${statusCode}";
                                if( statusCode == 'success' ){
                                    sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathwlBirc}/DeploysTemp/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension} -targets ${clusterWlBirc} -usenonexclusivelock"

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
                    println "Stage Deploy <<<<<< success >>>>>>"
                    script{
                        statusCode='success';
                    }                    
                            echo "backup ";
                            sshCommand remote: remote, command:"cd ${pathwlBirc}/Deploy/${JOB_BASE_NAME} && mv ${artifactNameWlBirc}.${extension} ${artifactNameWlBirc}_`date +\"%Y-%m-%d-%Y_%H:%M\"`.${extension} && mv * ${pathwlBirc}/DeploysHistory/${JOB_BASE_NAME}"

                            sshCommand remote: remote, command:"cd ${pathwlBirc}/DeploysTemp/${JOB_BASE_NAME} && mv ${artifactNameWlBirc}.${extension}  ${pathwlBirc}/Deploy/${JOB_BASE_NAME}"
                        
                    }
                unstable {
                    println "Stage Deploy <<<<<< unstable >>>>>>"
                    script{
                        statusCode='unstable';
                    }
                }
                failure {
                    println "Stage Deploy <<<<<< failure >>>>>>"
                    withCredentials([file(credentialsId: "${idKeyWlSshBirc}",variable: 'KeyWlSshBirc')]){//refactoring
                        script{
                            if( statusCode == 'success' ){

                                echo "1. eleminar el contenido de la carpeta Temp, existe porque el Undeploy fue exitoso";
                                sshCommand remote: remote, command:"cd rm -rf ${pathwlBirc}/DeploysTemp/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension}"
                               
                                echo "2. desplegar de la carpeta deploy";
                                sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathwlBirc}/Deploy/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension} -targets ${clusterWlBirc} -usenonexclusivelock"
                               
                                echo "3. start a la aplicación";
                                sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWlBirc}"
                               
                            }
                            if( statusCode == 'failure' || statusCode == 'unstable' ){

                                echo "No es posible realizar el Deploy, se despliega la versión anterior.";
                                sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathwlBirc}/Deploy/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension} -targets ${clusterWlBirc} -usenonexclusivelock"

                                echo "start aplicación";
                                sshCommand remote: remote, command: "cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWlBirc}"
                            }
                            statusCode='failure';
                        }
                    }
                }
            }
                
        } 

    }
    post {         
        always{
            echo "Enviar logs...";
        }
        
        //Manejo de las execepciones con envio de notificacion por medio de slack  segun del status que coresponda.
        success{
            script{
                if( "${BRANCH_NAME}" == "devops" || "${BRANCH_NAME}" == "qa" || "${BRANCH_NAME}" == "master" ){
                    slackSend color: '#90FF33', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: success  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${serverWlSshBirc}:7001/FACTURAELECTRONICA/";

                }
            }
        }
        unstable {
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "qa" || "${BRANCH_NAME}" == "master" ){
                    slackSend color: '#FFA500', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: unstable \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${serverWlSshBirc}:7001/FACTURAELECTRONICA/";
                    }
                }
        }
        failure{
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "qa" || "${BRANCH_NAME}" == "master" ){
                    slackSend color: '#FF4233', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: failure  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${serverWlSshBirc}:7001/FACTURAELECTRONICA/";
                }
            }

        } 
    }     
    
}


