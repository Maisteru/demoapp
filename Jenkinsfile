pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'webapp'
    }

    stages {
        stage('Git Clone') {
            steps {
                // Klonowanie repozytorium
                git url: 'https://github.com/twoje-repozytorium.git', branch: 'master'
            }
        }

        stage('Build z Maven') {
            steps {
                // Budowanie aplikacji przy pomocy Maven
                sh 'mvn clean package'
            }
        }

        stage('Budowanie obrazu Docker') {
            steps {
                // Budowanie obrazu Docker na podstawie Dockerfile
                script {
                    docker.build("${env.DOCKER_IMAGE}")
                }
            }
        }

        stage('Uruchomienie kontenera') {
            steps {
                // Uruchomienie kontenera z aplikacją
                script {
                    docker.image("${env.DOCKER_IMAGE}").run("-p 8080:8080")
                }
            }
        }
    }
}
