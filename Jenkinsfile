pipeline {
    agent any

    environment {
        CONTAINER_NAME = "webapp_container"
        IMAGE_NAME = "webapp:${env.BUILD_ID}"
        PORT = "8081"
    }

    stages {
        stage('Prepare new text') {
            steps {
                script {
                    // Ustawienie zmiennej z datą budowy
                    def buildDate = new Date().format("yyyy-MM-dd HH:mm:ss", TimeZone.getTimeZone('UTC'))
                    // Ustawienie zmiennej z nazwą hosta
                    def hostName = sh(returnStdout: true, script: 'hostname').trim()
                    // Tekst do wstawienia
                    def newText = "Hello from ${hostName} at ${buildDate}"
                    // Komenda zmieniająca tekst w pliku index.jsp
                    sh "sed -i 's/Hello World../${newText}/g' src/main/webapp/index.jsp"
                }
            }
        }

//         stage('Git Clone') {
//             steps {
//                 // Klonowanie repozytorium
//                 git url: 'https://github.com/Maisteru/demoapp.git', branch: 'main'
//             }
//         }

        stage('Build z Maven') {
            steps {
                // Budowanie aplikacji przy pomocy Maven
                sh '''
                    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
                    mvn clean package
                    cp target/demo.war demo.war
                '''
            }
        }

        stage('Budowanie obrazu Docker i uruchomienie kontenera') {
            steps {
                // Budowanie obrazu Docker na podstawie Dockerfile
                script {
                    // Sprawdzenie, czy kontener już istnieje
                    def isRunning = sh(script: "docker ps --filter 'name=^/${CONTAINER_NAME}\$' --format '{{.Names}}'", returnStdout: true).trim()
                    def isExist = sh(script: "docker ps -a --filter 'name=^/${CONTAINER_NAME}\$' --format '{{.Names}}'", returnStdout: true).trim()

                    if(isRunning) {
                        // Jeśli kontener już działa, zatrzymaj go
                        sh "docker stop ${CONTAINER_NAME}"
                    }
                    if(isExist) {
                        // Jeśli kontener istnieje (działał lub był zatrzymany), usuń go
                        sh "docker rm ${CONTAINER_NAME}"
                    }

                    // Budowanie nowego obrazu
                    sh "docker build -t ${IMAGE_NAME} ."

                    // Uruchomienie kontenera z nowym obrazem
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${PORT}:8080 ${IMAGE_NAME}"

                }
            }
        }
    }
}
