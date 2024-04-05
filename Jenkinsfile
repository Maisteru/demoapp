pipeline {
    agent any

    // Setting variables used across the file
    environment {
        CONTAINER_NAME = "webapp_container"
        IMAGE_NAME = "webapp"
        GIT_URL = "https://github.com/Maisteru/demoapp.git"
        PORT = "8081"
        ECR_REGISTRY = "339713146598.dkr.ecr.eu-central-1.amazonaws.com"
        AWS_REGION = "eu-central-1"
        ECS_CLUSTER = "ecs-cluster"
        ECS_SERVICE = "webapp-deployment-lb"
        LOAD_BALANCER_DNS = "webapp-lb-1759269594.eu-central-1.elb.amazonaws.com"
    }

    stages {
        stage('Prepare new text') {
            steps {
                script {
                    // Set date variable, hostname and replace it in index.jsp
                    def buildDate = new Date().format("yyyy-MM-dd HH:mm:ss", TimeZone.getTimeZone('Europe/Warsaw'))
                    def hostName = sh(returnStdout: true, script: 'hostname').trim()
                    def newText = "Hello from ${hostName} at ${buildDate}"
                    sh "sed -i 's/Hello World../${newText}/g' src/main/webapp/index.jsp"
                }
            }
        }
//         Local testing purpose
//         stage('Git Clone') {
//             steps {
//                 // Clone github repo
//                 git url: '${GIT_URL}', branch: 'main'
//             }
//         }

        stage('Build z Maven') {
            steps {
                // Make sure right Java version is used and build application with Maven
                sh '''
                    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
                    mvn clean package
                    cp target/demo.war demo.war
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                // Build and run Docker image
                script {
//                     Local testing purpose
//                     def isRunning = sh(script: "docker ps --filter 'name=^/${CONTAINER_NAME}\$' --format '{{.Names}}'", returnStdout: true).trim()
//                     def isExist = sh(script: "docker ps -a --filter 'name=^/${CONTAINER_NAME}\$' --format '{{.Names}}'", returnStdout: true).trim()
//                     if(isRunning) {
//                         sh "docker stop ${CONTAINER_NAME}"
//                     }
//                     if(isExist) {
//                         sh "docker rm ${CONTAINER_NAME}"
//                     }
                    sh "docker build -t ${ECR_REGISTRY}/${IMAGE_NAME}:latest ."
//                     Local testing purpose
//                     sh "docker run -d --name ${CONTAINER_NAME} -p ${PORT}:8080 ${IMAGE_NAME}:latest"

                }
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                script {
                    // Use Jenkins credentials to log into ECR
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'jenkins_user']]) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${ECR_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Force New Deployment ECS Service') {
            steps {
                script {
                    // Force service redeployment on eCS
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'jenkins_user']]) {
                        sh "aws ecs update-service --region ${AWS_REGION} --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment"
                    }
                }
            }
        }

        stage('Check webserver availability') {
            steps {
                script {
                    /*
                        Wait for ECS service to redeploy application
                        If the HTTP status code is not 200-399 interprets as a failure
                    */
                    println "Wait 120 sec for redeployment"
                    sleep(120)
                    try {
                        sh """
                            curl -f http://${LOAD_BALANCER_DNS}/demo/health
                        """
                    } catch (Exception e) {
                        println "The health check failed. Service is unavailable :("
                    }
                }
            }
        }

        stage('Check instances availability') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'jenkins_user']]) {
                        // List instances in the ECS service
                        def instances = sh(script: "aws ecs list-container-instances --region ${AWS_REGION} --cluster ${ECS_CLUSTER} --query 'containerInstanceArns[]' --output text", returnStdout: true).trim().split()

                        // Get the EC2 instance IDs from the container instances
                        instances.each { instance ->
                            def instanceId = sh(script: "aws ecs describe-container-instances --region ${AWS_REGION} --cluster ${ECS_CLUSTER} --container-instances ${instance} --query 'containerInstances[].ec2InstanceId' --output text", returnStdout: true).trim()

                            // Get the IP address of the EC2 instance
                            def ipAddress = sh(script: "aws ec2 describe-instances --instance-ids --region ${AWS_REGION} ${instanceId} --query 'Reservations[].Instances[].PublicIpAddress' --output text", returnStdout: true).trim()

                            // Check the health of the instance directly via its IP
                            // This assumes you have a similar health check endpoint accessible directly
                            try {
                                sh "curl -f http://${ipAddress}:8080/demo/health"
                            } catch (Exception e) {
                                println "The health check failed. Instance ${ipAddress} is unavailable :("
                            }
                        }
                    }
                }
            }
        }

    }
}
