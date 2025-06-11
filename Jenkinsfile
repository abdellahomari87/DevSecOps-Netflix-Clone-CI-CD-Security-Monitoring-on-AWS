pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Frontend Code') {
            steps {
                git branch: 'main', url: 'https://github.com/abdellahomari87/Netflix-clone-abdellah.git'
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=Netflix \
                        -Dsonar.projectName=Netflix \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=http://localhost:9000
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('NPM Install & Audit') {
            steps {
                sh '''
                    npm install
                    npm audit --json > npm-audit-report.json || true
                '''
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'API_KEY')]) {
                   dependencyCheck additionalArguments: "--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${API_KEY}", odcInstallation: 'DP-Check'
                   dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh '''
                    mkdir -p trivy-report
                    trivy fs . \
                        --format json \
                        --output trivy-report/trivy-report.json || true
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*.json, owasp-report/*, dependency-check-report.xml', allowEmptyArchive: true
        }
    }
}
