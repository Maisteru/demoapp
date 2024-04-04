pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'webapp'
    }

    stages {
        stage('Git Clone') {
            steps {
                // Klonowanie repozytorium
                git url: 'https://github.com/Maisteru/demoapp.git', branch: 'master'
            }
        }

        stage('Build z Maven') {
            steps {
                // Budowanie aplikacji przy pomocy Maven
                sh '''
                    cd demoapp
                    mvn clean package
                    cp target/demo.war demo.war
                '''
            }
        }

        stage('Budowanie obrazu Docker i uruchomienie kontenera') {
            steps {
                // Budowanie obrazu Docker na podstawie Dockerfile
                script {
                    sh '''
                        docker build . -t demo_webapp
                        docker run -d -p 8080:8080 demo_webapp
                    '''

                }
            }
        }
    }
}
