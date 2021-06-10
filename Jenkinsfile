pipeline {
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
    }
    environment {
        statusCode = '';
    }  
    stages {   
        /*stage('SonarQube analysis') {
           agent any
           
           //when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } }
           steps {
               script {
                   last_stage = env.STAGE_NAME
                   //def SCANNERHOME  = tool 'sonar-scanner'
                    def SCANNERHOME = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                   //def projectKey="BIRC-TEST-DEPLOY-EAR-${BRANCH_NAME}"
                   def projectName='segurosbolivar_birc_test'
                   def projectKey='birc_test'
                   def organization='segurosbolivar'
                   def pathSourceSonar='Back/src/main/java/'
                   def sonarURL='192.168.0.20:9000'
                   def jacoco_reportPaths='target/jacoco.exec'
                   def junit_reportPaths='target/surefire-reports'

                   withSonarQubeEnv('SonarCloud'){
                         sh """
                           ${SCANNERHOME}/bin/sonar-scanner -e -Dsonar.java.binaries=. -Dsonar.projectName=${projectName} -Dsonar.projectKey=${projectKey} -Dsonar.organization=${organization} -Dsonar.sources=${pathSourceSonar} -Dsonar.host.url=${sonarURL} -Dsonar.jacoco.reportPaths=${jacoco_reportPaths} -Dsonar.junit.reportPaths=${junit_reportPaths} 
                         """
                   }
               }
               echo "SonarQube analysis";              
           }
        }
        stage("Quality gate") {
            when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } }
            steps {
                script {
                    last_stage = env.STAGE_NAME
                }
                waitForQualityGate abortPipeline: true
             }*/
            /*steps {
                script {
                    echo "Quality gate";
                }
             }*/
        //}
        stage("Build") {
            when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } }
            steps {
                echo "build Pendiente Definición"
            }
        }
        stage('Set variables'){
            agent {
                label 'master' 
            }
            when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
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
                withCredentials([
                    file(
                        credentialsId: "${idKeyWlSshBirc}",
                        variable: 'KeyWlSshBirc'), 
                    usernamePassword(
                        credentialsId: "${idUserANDPassWlBirc}", 
                        usernameVariable: 'userwlBirc', passwordVariable: 'passwlBirc')
                ]){ 
                   sh """
                       sh pipelineFiles/SetVariables/env.sh ${urlWlBirc} ${userwlBirc} ${passwlBirc} ${artifactNameWlBirc} ${domainWlBirc} ${pathwlBirc} ${clusterWlBirc} ${serverWlSshBirc} ${puertoWlSshBirc} ${KeyWlSshBirc} ${extension}
                   """
                }
            }
       }
       stage('Stop App'){
           agent {
                label 'master' 
           }                
           when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps {
                catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                     withCredentials([
                        file(
                            credentialsId: "${idKeyWlSshBirc}",
                            variable: 'KeyWlSshBirc'), 
                        usernamePassword(
                            credentialsId: "${idUserANDPassWlBirc}",
                            usernameVariable: 'userwlBirc', passwordVariable: 'passwlBirc')
                     ]){
                         sh """
                             ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/StopApp/StopApp.sh' ${JOB_BASE_NAME}
                         """
                     }
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
           when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps{
                catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                    withCredentials([
                        file(
                            credentialsId: "${idKeyWlSshBirc}",
                            variable: 'KeyWlSshBirc'), 
                        usernamePassword(
                            credentialsId: "${idUserANDPassWlBirc}",
                            usernameVariable: 'userwlBirc', passwordVariable: 'passwlBirc')
                    ]){
                        script{
                             echo "Estatus Code Stage Anterior(Stop App): ${statusCode}";
                             if( statusCode == 'success' ){
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/Undeploy/Undeploy.sh' ${JOB_BASE_NAME}
                                """
                             }
                             if( statusCode == 'failure' || statusCode == 'unstable' ){
                                  autoCancelled = true
                                  error('Aborting the build.')
                             }
                        }
                    }
                }               
           }
           post {
               success {
                   println "Stage Undeploy <<<<<< success >>>>>>"
                   script{
                        statusCode='success';
                   } 
                   withCredentials([
                        file(
                            credentialsId: "${idKeyWlSshBirc}",
                            variable: 'KeyWlSshBirc')
                        ]){
                        echo "Copy ear to Server Web Logic";
                        sh """
                            scp -i ${KeyWlSshBirc} -P ${puertoWlSshBirc} Despliegue/${artifactNameWlBirc}.${extension} oracle@${serverWlSshBirc}:${pathwlBirc}/DeploysTemp/${JOB_BASE_NAME}
                        """
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
                    withCredentials([file(credentialsId: "${idKeyWlSshBirc}",variable: 'KeyWlSshBirc')]){    
                        script{
                            echo "Start App";
                            if( statusCode == 'success' ){
                                sh"""
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/StartApp/Start.sh' ${JOB_BASE_NAME}
                                """  
                            }                           
                            statusCode='failure';
                        }
                    }
               }
           }
        }
        stage('Deploy'){      
           agent {
                label 'master' 
           }          
           when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps{
               catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                    withCredentials([
                         file(
                              credentialsId: "${idKeyWlSshBirc}",
                              variable: 'KeyWlSshBirc'), 
                         usernamePassword(
                              credentialsId: "${idUserANDPassWlBirc}",
                              usernameVariable: 'userwlBirc', passwordVariable: 'passwlBirc')
                        ]){
                           script{
                                echo "Estatus Code Stage Anterior (Undeploy): ${statusCode}";
                                if( statusCode == 'success' ){
                                    sh"""
                                        ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/Deploy/Deploy.sh' ${JOB_BASE_NAME}
                                    """
                                }
                                if( statusCode == 'failure' || statusCode == 'unstable' ){
                                     autoCancelled = true
                                     error('Aborting the build.')
                                }
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
                    withCredentials([file(credentialsId: "${idKeyWlSshBirc}",variable: 'KeyWlSshBirc')]){                    
                        echo "backup ";
                            sh """
                                ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/Backup/backupEar.sh' ${JOB_BASE_NAME}
                            """
                        }
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
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'rm -rf ${pathwlBirc}/DeploysTemp/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension}'
                                """
                                echo "2. desplegar de la carpeta deploy";
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/Deploy/DeployErr.sh' ${JOB_BASE_NAME}
                                """
                                echo "3. start a la aplicación";
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/StartApp/Start.sh' ${JOB_BASE_NAME}
                                """
                            }
                            if( statusCode == 'failure' || statusCode == 'unstable' ){
                                echo "No es posible realizar el Deploy, se despliega la versión anterior.";
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/Deploy/DeployErr.sh' ${JOB_BASE_NAME}
                                """
                                echo "start aplicación";
                                sh """
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/StartApp/Start.sh' ${JOB_BASE_NAME}
                                """
                            }
                            statusCode='failure';
                        }
                    }
                }
            }
       } 
       /*stage('Start App'){
           agent {
                label 'master' 
           }     
           when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } } //only qa
           steps{
                catchError(buildResult: 'UNSTABLE', catchInterruptions: false, message: 'stage failed', stageResult: 'FAILURE') {
                    withCredentials([file(credentialsId: "${idKeyWlSshBirc}",variable: 'KeyWlSshBirc')]){
                        script{
                            echo "Estatus Code Stage Anterior(Deploy): ${statusCode}";
                            if( statusCode == 'success' ){
                                sh"""
                                    ssh -i ${KeyWlSshBirc} -p ${puertoWlSshBirc} oracle@${serverWlSshBirc} 'sh ${pathwlBirc}/Shell/StartApp/Start.sh' ${JOB_BASE_NAME}
                                """ 
                            }
                            if( statusCode == 'failure' || statusCode == 'unstable' ){
                                autoCancelled = true
                                error('Aborting the build.')
                            }
                        }               
                    }
                }
           }
           post {
               success {
                   println "Stage Start App <<<<<< success >>>>>>"
               }
               unstable {
                   println "Stage Start App <<<<<< unstable >>>>>>"
               }
               failure {
                   println "Stage Start App <<<<<< failure >>>>>>"
               }
           }
       }*/
    }
    post {
        always{
            echo "Enviar logs...";
            cleanWs();
        }
        success{
            echo "success";
        }
        failure{
            echo "failure";
        }          
    }
}