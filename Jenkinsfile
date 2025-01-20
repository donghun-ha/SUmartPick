pipeline {
    agent any

    environment {
        DOCKER_IMAGE_TAG = "SUmartPick-${BUILD_NUMBER}"
        ECR_REPO = "664418991926.dkr.ecr.ap-northeast-2.amazonaws.com/sumartpick"
        AWS_REGION = "ap-northeast-2"
        TMP_WORKSPACE = "/tmp/jenkins_workspace"
        AWS_ACCESS_KEY_ID = credentials('sumartpick_jenkins')
        AWS_SECRET_ACCESS_KEY = credentials('sumartpick_jenkins')
    }

    stages {
        stage("Init") {
            steps {
                script {
                    gv = load "script.groovy"
                }
            }
        }
        stage("Checkout") {
            steps {
                checkout scm
            }
        }
        stage("Debug Environment") {
            steps {
                sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
                    echo "AWS_REGION: $AWS_REGION"
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker Image with tag: ${DOCKER_IMAGE_TAG}"
                    cd /var/lib/jenkins/workspace/SumartPick-pipeline
                    docker build -t ${ECR_REPO}:${DOCKER_IMAGE_TAG} -f Dockerfile .
                    docker tag ${ECR_REPO}:${DOCKER_IMAGE_TAG} ${ECR_REPO}:latest
                '''
            }
        }
        stage('Push Docker Image to ECR Repo') {
            steps {
                withAWS(credentials: 'sumartpick_jenkins', region: "${AWS_REGION}") {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "${ECR_REPO}"
                        echo "Pushing Docker Image with tag: ${DOCKER_IMAGE_TAG}"
                        docker push "${ECR_REPO}:${DOCKER_IMAGE_TAG}"
                        echo "Pushing Docker Image with tag: latest"
                        docker push "${ECR_REPO}:latest"
                    '''
                }
            }
        }
        stage("Deploy") {
            steps {
                sh '''
                    echo "Deploying Docker Image with tag: ${DOCKER_IMAGE_TAG}"
                    export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}
                    export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                    docker-compose -f docker-compose.yml up -d
                '''
            }
        }
    }
}