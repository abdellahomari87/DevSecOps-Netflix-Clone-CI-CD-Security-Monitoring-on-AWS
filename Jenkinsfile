pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        NVD_API_KEY = credentials('NVD_API_KEY')
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
                sh '''
                    mkdir -p owasp-report
                    dependency-check --scan . \
                                     --format HTML --format XML \
                                     --out owasp-report \
                                     --project Netflix \
                                     --disableYarnAudit \
                                     --disableNodeAudit \
                                     --nvdApiKey ${NVD_API_KEY}
                                     --data /var/lib/jenkins/owasp-data
                ''' // ⬅️ Generates HTML & XML
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh '''
                    mkdir -p trivy-report
                    trivy fs . --format html --output trivy-report/trivy-report.html || true
                ''' // ⬅️ Generates HTML
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*.json, trivy-report/trivy-report.html, owasp-report/dependency-check-report.html', allowEmptyArchive: true
        }
    }
}