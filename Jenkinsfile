
pipeline {
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
    }
    stages {
        stage('Test'){
          when { anyOf { branch 'develop'; branch 'qa'; branch 'stage'; branch 'master' } }
           agent {
                label 'Linux'
           } 
           steps {
               sh './pipelineFiles/test/test.sh mvn test'
               stash includes: 'Back/target/', name: 'mysrc'
           }
        }
        stage('SonarQube analysis') {
           when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }  
           steps {
               script {
                   last_stage = env.STAGE_NAME
                   def SCANNERHOME = tool name: 'SonarQube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'

                    unstash 'mysrc'
                    // sh """
                    //  ${SCANNERHOME}/bin/sonar-scanner -X -Dproject.settings=sonar-project.properties -Dsonar.projectVersion=0.${BUILD_NUMBER}
                    // """                  
                   
                    // unstash 'mysrc'
                    
                    // if( BRANCH_NAME != 'master'){
                    //     branchSonar=BRANCH_NAME
                    // }
                    
                    withSonarQubeEnv('SonarQube') {
                        echo 'sonar'
                        sh """
                                ${SCANNERHOME}/bin/sonar-scanner \
                                    -Dsonar.projectKey=Test-Sonar-${BRANCH_NAME} \
                                    -Dsonar.projectName=Test-Sonar-${BRANCH_NAME} \
                            """
                    }
                }
            }                            
        }
    }
}

        




