pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'webapp'
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

        stage('Git Clone') {
            steps {
                // Klonowanie repozytorium
                git url: 'https://github.com/Maisteru/demoapp.git', branch: 'main'
            }
        }

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
                    sh '''
                        docker build . -t demo_webapp
                        docker run -d -p 8081:8080 demo_webapp
                    '''

                }
            }
        }
    }
}
