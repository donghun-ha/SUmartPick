pipeline {
    agent any // Jenkins가 어떤 노드에서든 실행되도록 설정

    environment {
        DOCKER_IMAGE_TAG = "SUmartPick-${BUILD_NUMBER}"  // 빌드 번호를 포함한 고유한 Docker 이미지 태그
        ECR_REPO = "664418991926.dkr.ecr.ap-northeast-2.amazonaws.com/sumartpick" // Amazon ECR 저장소 URL
        AWS_REGION = "ap-northeast-2" // AWS 리전(서버가 있는 지역) 설정
        TMP_WORKSPACE = "/tmp/jenkins_workspace"  // 임시 작업을 저장할 폴더
        AWS_ACCESS_KEY_ID = credentials('sumartpick_jenkins') // AWS 접근 ID를 Jenkins 자격증명에서 가져옴
        AWS_SECRET_ACCESS_KEY = credentials('sumartpick_jenkins') // AWS 비밀번호를 Jenkins 자격증명에서 가져옴
    }

    stages {
        stage("Init") { // 파이프라인 초기화 단계
            steps {
                script {
                    gv = load "script.groovy" // 외부에 있는 "script.groovy" 파일을 로드
                }
            }
        }
        stage("Checkout") { // GitHub에서 코드를 가져오는 단계
            steps {
                checkout scm // Git 저장소에서 현재 브랜치의 코드를 가져옴
            }
        }
        stage("Debug Environment") { // 환경 변수 확인 단계 (디버그 용도)
            steps {
                sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID" // AWS 접근 ID를 출력
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY" // AWS 비밀번호를 출력
                    echo "AWS_REGION: $AWS_REGION" // 설정된 AWS 리전을 출력
                '''
            }
        }
        stage('Build Docker Image') { // Docker 이미지를 생성하는 단계
            steps {
                sh '''
                    echo "Building Docker Image with tag: ${DOCKER_IMAGE_TAG}" // Docker 이미지를 빌드한다고 출력
                    docker build -t ${ECR_REPO}:${DOCKER_IMAGE_TAG} -f Dockerfile . // Docker 이미지를 지정된 태그로 생성
                    echo "Tagging image as latest" // 최신 태그로 이미지에 추가 태그를 붙였다고 출력
                    docker tag ${ECR_REPO}:${DOCKER_IMAGE_TAG} ${ECR_REPO}:latest // 이미지를 'latest'라는 이름으로 태그
                '''
            }
        }
        stage('Push Docker Image to ECR Repo') { // Docker 이미지를 Amazon ECR 저장소로 업로드하는 단계
            steps {
                withAWS(credentials: 'sumartpick_jenkins', region: "${AWS_REGION}") { // AWS 인증 정보를 사용
                    sh '''
                        # ECR 로그인
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "${ECR_REPO}"
                        
                        # 고유한 태그로 이미지 푸시
                        echo "Pushing Docker Image with tag: ${DOCKER_IMAGE_TAG}" // 고유 태그로 이미지를 푸시한다고 출력
                        docker push "${ECR_REPO}:${DOCKER_IMAGE_TAG}" // 고유 태그를 가진 이미지를 ECR에 업로드
                        
                        # 'latest' 태그로 이미지 푸시
                        echo "Pushing Docker Image with tag: latest" // 최신 태그로 이미지를 푸시한다고 출력
                        docker push "${ECR_REPO}:latest" // 최신 태그를 가진 이미지를 ECR에 업로드
                    '''
                }
            }
        }
        stage("Deploy") { // 애플리케이션을 배포하는 단계
            steps {
                sh '''
                    echo "Deploying Docker Image with tag: ${DOCKER_IMAGE_TAG}" // Docker 이미지를 배포한다고 출력
                    DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} \ // Docker 이미지 태그를 환경 변수로 설정
                    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \ // AWS 접근 ID를 환경 변수로 설정
                    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \ // AWS 비밀번호를 환경 변수로 설정
                    docker-compose -f docker-compose.yml up -d // Docker Compose로 컨테이너를 실행
                '''
            }
        }
    }
}