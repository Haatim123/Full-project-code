# Deploy build files to an Nginx server using Ansible and Jenkins:
**Overall Steps:**
1. Install Ansible:
   Install Ansible on the Jenkins server or a dedicated Ansible control node:
   sudo apt update
   sudo apt install ansible -y
2. Nginx server must be up
3. Configure Nginx:
   Ensure the root directory (e.g., /var/www/html) is configured properly in the Nginx configuration file:
   sudo vim /etc/nginx/sites-available/default
 Example configuration: 
 server {
    listen 80;
    server_name your-domain.com;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}

Reload Nginx: sudo systemctl reload nginx

# Key-Based Authentication Setup
1. Generate SSH Key on Jenkins Server:
   On the Jenkins server, generate an SSH key pair 
   ssh-keygen -t rsa -b 4096
  Save the key pair (e.g., ~/.ssh/id_rsa).
2. Copy Public Key to Nginx Server:
   Copy the public key to the Nginx server:
   ssh-copy-id -i ~/.ssh/id_rsa.pub user@nginx-server
3. Test the connection:
   ssh user@nginx-server
4. Add SSH Key to Jenkins:
  Go to Manage Jenkins → Credentials.
  Add the private SSH key (~/.ssh/id_rsa) as a new SSH credential.
# Configure Ansible
1. Ansible Inventory File:
  Create or edit an inventory file for the target server
  [nginx]
  nginx-server ansible_host=<nginx_server_ip>
2. Ansible Configuration:
  Configure Ansible to use the inventory file: 
  sudo vim /etc/ansible/ansible.cfg
  Example configuration:
  [defaults]
inventory = /path/to/inventory
remote_user = <user>
private_key_file = ~/.ssh/id_rsa
host_key_checking = False

3. Ansible Playbook:
  Write an Ansible playbook to deploy the build files 

  # deploy-files.yml
- name: Deploy Build Files to Nginx Server
  hosts: nginx
  tasks:
    - name: Clean the existing Nginx web root directory
      file:
        path: /var/www/html/
        state: absent

    - name: Recreate the Nginx web root directory
      file:
        path: /var/www/html/
        state: directory
        mode: '0755'

    - name: Copy build files to the Nginx server
      copy:
        src: /path/to/jenkins/workspace/build/
        dest: /var/www/html/
        owner: nginx
        group: nginx
        mode: '0755'

    - name: Restart Nginx to apply changes
      service:
        name: nginx
        state: restarted

# Configure Jenkins Pipeline

1. Install Jenkins Plugins:
   Install the "Ansible" plugin in Jenkins: Go to Manage Jenkins → Plugin Manager → Available → Search for Ansible.
2. Configure Ansible in Jenkins:
  Go to Manage Jenkins → Global Tool Configuration.
  Add Ansible under Ansible installations: 
  Name: Ansible 
  installation path: /usr/bin/ansible or the path where Ansible is installed.
3. Write Jenkinsfile:

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

# Execution Steps: 
1. Commit Build and Playbook Files:
  Push the build and Ansible playbook files to the Git repository.
2. Run the Jenkins Job:
  Trigger the Jenkins pipeline.
  Jenkins will: 
  1. Build the frontend application (npm run build).
  2. Copy the generated build/ folder to the Nginx server using Ansible.

3. Verify Deployment:
   Access the application in the browser via the Nginx server IP or domain name.

  