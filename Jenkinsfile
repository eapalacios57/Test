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