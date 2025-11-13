pipeline {
    agent any

    environment {
        APP_NAME = "spring-app"
        DOCKER_IMAGE = "taphasr1/${APP_NAME}:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Moustapha124/spring-maven.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarScanner'
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.projectName=${APP_NAME}
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '13.48.123.84:8081',
                    groupId: 'com.moustapha',
                    version: '1.0.0',
                    repository: 'maven-releases',
                    credentialsId: 'nexus-credential',
                    artifacts: [
                        [artifactId: APP_NAME, file: 'target/demo-github-0.0.1-SNAPSHOT.jar', type: 'jar']
                    ]
                )
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Trivy Scan') {
            steps {
                sh """
                    trivy image --exit-code 1 --ignore-unfixed ${DOCKER_IMAGE}
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKERHUB',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ''' + DOCKER_IMAGE + '''
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline CI/CD terminé avec succès sur l'instance 13.48.123.84 !"
        }
        failure {
            echo "❌ Pipeline échouée ! Vérifiez les logs Jenkins."
        }
    }
}
