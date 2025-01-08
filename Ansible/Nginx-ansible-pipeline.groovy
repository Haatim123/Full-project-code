pipeline {
    agent any
    stages {
        stage('Build Application') {
            steps {
                sh '''
                npm install
                npm run build
                '''
            }
        }
        stage('Deploy to Nginx') {
            steps {
                ansiblePlaybook credentialsId: 'ansible-ssh-credential-id',
                                inventory: '/path/to/inventory',
                                playbook: '/path/to/deploy-files.yml',
                                extras: '-e src_path=${WORKSPACE}/build'
            }
        }
    }
}