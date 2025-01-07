pipeline{
    agent any
    stages{
        stage('checkout'){
            steps{
                checkout ([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: '']]

                ])
            }

        }
        stage('Terraform init'){
            steps{
                sh 'Terraform init -reconfigure'
            }
        }
        stage('Terraform plan'){
            steps{
                sh 'Terraform plan'
            }
        }
        stage('Action'){
            steps{
                //  we are using this project is  parameterized option -> choice parameter
                echo "Terraform action is --> ${action}"
                sh ("terraform $(action) --auto-aprove")  
            }
        }
    }
}