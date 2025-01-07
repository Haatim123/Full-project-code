// Frontend Deployment Pipeline

pipeline {
    agent any
    environment{
        ECR_REGISTRY = "Ecr-registry-url"  # this is ECR registry url 
        FRONTEND_REPO_NAME = "Frontend-app" # This is ECR repo name in ECR
        AWS_REGION = "us-east-1" # Region in which our resources are available
        PATH = "/usr/local/bin/:${env.PATH}"
    }
    stages{
       stage('checkout'){
           steps {
             checkout([ 
             $class:'GitSCM',
             branches: [["*/main"]],
             userRemoteConfigs[[url : ""]]    //provide frontend url
             extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'frontend']]      //The repository is cloned into the frontend folder.
            ])
           }
       }
       stage('Install AWS CLI'){
           steps{
             sh 'curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip'
             sh 'unzip -o awscliv2.zip'
             sh './aws/install --update'
           }
       }
       stage('Install Helm'){
           steps{
             sh 'curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash'
           }
       }
       stage('Build app'){
           steps{
            withEnv(["HOME=${env.WORKSPACE}"]){
                dir('frontend'){
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
           }
       }
       stage('build-docker-image'){
           steps{
               script{
                sh 'docker build -t "$ECR_REGISTRY/$FRONTEND_REPO_NAME:latest" ./frontend'
                sh 'docker image ls'
              }
           }
       }
       stage('push-image-to-ECR'){
           steps{
             script {
                sh  'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$FRONTEND_REPO_NAME:latest"'
             }
           }
       }
       stage('Approval Before Deployment'){
           steps{
              input message:'Approve deployment to kubernetes?',
              ok: 'Deploy', //Users must have at least BUILD permissions to approve the pipeline.
              submitter: 'admin,team-lead' // Replace with Jenkins usernames
           }
       }
       stage('Deploy to kubernetes'){
           steps{
              script{
                sh 'aws eks update-kubeconfig --region $AWS_REGION --name dev-cluster'
                sh 'helm upgrade --install frontend ./helm/frontend' //replace correct path of helm chart for frontend
           }  }
       }
    } 
    post {
        success {
            slackSend(channel: '#frontend-builds', message: "frontend build and deployment successfull!")
        }
        failure {
            slackSend(channel: '#frontend-builds', message: "frontend build or deployment failed!")
        }
    }
}