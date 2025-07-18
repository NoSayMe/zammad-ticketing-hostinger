pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }

    stages {
        stage('1. Checkout') {
            steps {
                echo '📥 Checking out repository...'
                checkout scm
            }
        }

        stage('2. Build Images') {
            steps {
                script {
                    echo '🏗️ Building Docker images (if any)...'
                    withCredentials([string(credentialsId: 'docker-registry', variable: 'DOCKER_REGISTRY')]) {
                        def servicesDir = 'services'
                        if (fileExists(servicesDir)) {
                            def services = sh(script: "ls ${servicesDir}", returnStdout: true).trim().split('\n')
                            for (service in services) {
                                if (fileExists("${servicesDir}/${service}/Dockerfile")) {
                                    sh """
                                        docker build -t \$DOCKER_REGISTRY/${service}:latest -f ${servicesDir}/${service}/Dockerfile ${servicesDir}
                                        docker tag \$DOCKER_REGISTRY/${service}:latest \$DOCKER_REGISTRY/${service}:${BUILD_NUMBER}
                                    """
                                }
                            }
                        } else {
                            echo 'No custom services directory found – skipping build stage.'
                        }
                    }
                }
            }
        }

        stage('3. Push to DockerHub') {
            steps {
                script {
                    echo '📤 Pushing Docker images (if any)...'
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    withCredentials([string(credentialsId: 'docker-registry', variable: 'DOCKER_REGISTRY')]) {
                        def servicesDir = 'services'
                        if (fileExists(servicesDir)) {
                            def services = sh(script: "ls ${servicesDir}", returnStdout: true).trim().split('\n')
                            for (service in services) {
                                if (fileExists("${servicesDir}/${service}/Dockerfile")) {
                                    sh """
                                        docker push \$DOCKER_REGISTRY/${service}:latest
                                        docker push \$DOCKER_REGISTRY/${service}:${BUILD_NUMBER}
                                    """
                                }
                            }
                        } else {
                            echo 'No Docker images to push.'
                        }
                    }
                }
            }
        }

        stage('4. Deploy to Remote Server') {
            steps {
                script {
                    echo '🚀 Deploying to server...'
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh-remote-server-hostinger-deploy', keyFileVariable: 'SSH_KEY'),
                        string(credentialsId: 'remote-user', variable: 'REMOTE_USER'),
                        string(credentialsId: 'remote-hostinger-deploy-ip', variable: 'REMOTE_HOST'),
                        string(credentialsId: 'docker-registry', variable: 'DOCKER_REGISTRY'),
                        string(credentialsId: 'remote-hostinger-domain', variable: 'REMOTE_DOMAIN'),
                        string(credentialsId: 'certbot-email', variable: 'CERTBOT_EMAIL')
                    ]) {
                        sh '''
                            mkdir -p /var/lib/jenkins/.ssh
                            ssh-keyscan "$REMOTE_HOST" >> /var/lib/jenkins/.ssh/known_hosts
                            chmod 600 /var/lib/jenkins/.ssh/known_hosts
                            ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "sudo mkdir -p /opt/zammad && sudo chown $REMOTE_USER:$REMOTE_USER /opt/zammad"
                            scp -i "$SSH_KEY" -o StrictHostKeyChecking=no docker-compose.yaml "$REMOTE_USER@$REMOTE_HOST:/opt/zammad/"
                            scp -i "$SSH_KEY" -o StrictHostKeyChecking=no deploy-script.sh "$REMOTE_USER@$REMOTE_HOST:/opt/zammad/"
                            scp -i "$SSH_KEY" -o StrictHostKeyChecking=no .env.example "$REMOTE_USER@$REMOTE_HOST:/opt/zammad/.env"
                            ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "cd /opt/zammad && chmod +x deploy-script.sh && ./deploy-script.sh '$DOCKER_REGISTRY' '$REMOTE_HOST' '$REMOTE_DOMAIN' '$CERTBOT_EMAIL'"
                        '''
                    }
                }
            }
        }

        stage('Initialize Zammad Admin') {
            steps {
                script {
                    echo '🔐 Initializing Zammad admin...'
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh-remote-server-hostinger-deploy', keyFileVariable: 'SSH_KEY'),
                        string(credentialsId: 'remote-user', variable: 'REMOTE_USER'),
                        string(credentialsId: 'remote-hostinger-deploy-ip', variable: 'REMOTE_HOST'),
                        string(credentialsId: 'zammad-admin-email', variable: 'ZAMMAD_ADMIN_EMAIL'),
                        string(credentialsId: 'zammad-admin-password', variable: 'ZAMMAD_ADMIN_PASSWORD')
                    ]) {
                        sh '''
                            ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" \
                            "docker exec zammad zammad run rake \"zammad:make_admin[$ZAMMAD_ADMIN_EMAIL,$ZAMMAD_ADMIN_PASSWORD]\""
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up local Docker images...'
            sh 'docker image prune -a -f'
        }
    }
}
