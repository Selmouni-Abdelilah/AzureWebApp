pipeline {
    agent any
    tools {
        terraform "terraform"
    }
    environment {
        WEBAPP_NAME = "webapp1937"  
        RES_GROUP = "my_rg" 
        WORKSPACE_NAME = "azurejenkinsworkspace17"
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'GitHubcredentials', url: 'https://github.com/Selmouni-Abdelilah/AzureWebApp ']])
                }
            }
        }
        stage('Azure login'){
            steps{
                withCredentials([azureServicePrincipal('Azure_credentials')]) {
                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                }
            }
        }
        stage('Terraform ') {
            steps {
                script {
                    dir('terraform') {
                    sh 'terraform init -upgrade'
                    sh "terraform apply --auto-approve  -var='rg_shared_name=${WEBAPP_NAME}' -var='webappnamename=${RES_GROUP} -var='workspacename=${WORKSPACE_NAME}'"
                    }
                }
            }    
        }
        stage('Pushing logs') {
            steps {
                script {    
                    sh "az webapp log config --name ${WEBAPP_NAME} --resource-group ${RES_GROUP} --application-logging true --detailed-error-messages true --web-server-logging filesystem"

                    def resourceID = sh(script: "az webapp show -g ${RES_GROUP} -n ${WEBAPP_NAME} --query id --output tsv", returnStdout: true).trim()
                    def workspaceID = sh(script: "az monitor log-analytics workspace show -g ${RES_GROUP} --workspace-name ${WORKSPACE_NAME} --query id --output tsv", returnStdout: true).trim()

                    sh "az monitor diagnostic-settings create --resource ${resourceID} --workspace ${workspaceID} -n myMonitorLogs --logs '[{\"category\": \"AppServiceHTTPLogs\", \"enabled\": true}]'"
                }
            }
        }

    }

}
