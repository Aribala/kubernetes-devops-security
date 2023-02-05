@Library('slack-notification') _

pipeline {
  agent any

  environment{
    imageName = "aribala/numeric-app:${GIT_COMMIT}"
    serviceName = "devsecops-svc"
    applicationURL = "http://aribala-devsecops.eastus.cloudapp.azure.com"
    applicationURI = "/increment/99"
    deploymentName = "devsecops"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
              echo "PUSH BUILD SUCCESS!!!"
            }
        } 
        
        stage('Unit Test Using Jacoco') {
            steps {
              sh "mvn test"
            }
        }
        
        // stage('Sonarqube test') {
        //     steps {
        //       sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-app  -Dsonar.host.url=http://aribala-devsecops.eastus.cloudapp.azure.com:9000 -Dsonar.login=sqp_9558c74c7b69630ce736ed34c7f983c1036e609b"
        //     }
        // }
        
        stage('Docker Build and push') {
            steps {
            	withDockerRegistry([credentialsId: "docker-hub", url: ""]){
	              sh "printenv"
    	          sh 'docker build -t aribala/numeric-app:""$GIT_COMMIT"" .'
        	      sh 'docker push aribala/numeric-app:""$GIT_COMMIT""'
            	}
            }
        }   

        stage('Vulnerability Scan - Kubernetes') {
            steps {
                parallel(
                    "OPA Scan": {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    },
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh"
                    }
                    ,
                    "Trivy Scan": {
                        sh "bash trivy-scan.sh"
                    }
                )                
            }
        }

        // stage('Kubernetes Deployment - DEV') {
        //     steps {
        //     	withKubeConfig([credentialsId: "kubeconfig"]){
	    //           sh "sed -i 's#replace#aribala/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
	    //           sh "kubectl apply -f k8s_deployment_service.yaml"
        //     	}
        //     }
        // }

        // stage('Integration Test') {
        //     steps {
        //         script {
        //             try {
        //                 withKubeConfig([credentialsId: "kubeconfig"]){
        //                     sh "bash integration-test.sh"
        //                 }
        //             } catch(e) {
        //                 withKubeConfig([credentialsId: "kubeconfig"]){
        //                     sh "kubectl -n default rollout undo deploy ${deploymentName}"
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('OWASP ZAP -DAST') {
        //     steps {
        //         withKubeConfig([credentialsId: "kubeconfig"]){
        //             sh "bash zap.sh"
        //         }
        //     }
        // }

        stage('K8S Deployment -PROD') {
            steps {
                parallel(
                    "Deployment": {
                        withKubeConfig([credentialsId: "kubeconfig"]){
                            sh "sed -i 's#replace#${imageName}#g' k8s_PROD_deployment_service.yaml"
                            sh "kubectl -n prod apply -f k8s_PROD_deployment_service.yaml"
                        }
                    },
                    "Rollout Status": {
                        withKubeConfig([credentialsId: "kubeconfig"]){
                            sh "kubectl -n prod apply -f k8s_PROD_deployment_rollout-status.sh"
                        }
                    }
                )
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP Report', reportTitles: 'OWASP ZAP Report', useWrapperFileDirectly: true])

            slackNotifications currentBuild.result
            cleanWs()
        }
    }
}
