pipeline{

	agent any

    environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
	}

	stages {
	    
	    stage('gitclone') {

			steps {
				git 'https://github.com/tangiang0812/mern-chat-backend.git'
			}
		}

		stage('Build') {

			steps {
				sh 'docker build -t gnaig/mern-chat-app .'
			}
		}

		stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		stage('Push') {

			steps {
				sh 'docker push gnaig/mern-chat-app'
			}
		}
		
    stage('Deploy') {
		    steps {
	            withCredentials([sshUserPrivateKey(credentialsId: "app_server_ssh", keyFileVariable: 'keyfile'), string(credentialsId: 'mongo_uri', variable: 'mongo_uri')]) {
                    sh 'ssh -o StrictHostKeyChecking=no -i ${keyfile} admin@ec2-18-143-65-82.ap-southeast-1.compute.amazonaws.com "docker stop mern-chat-app"'
                    sh 'ssh -o StrictHostKeyChecking=no -i ${keyfile} admin@ec2-18-143-65-82.ap-southeast-1.compute.amazonaws.com "docker rm mern-chat-app"'
                    sh 'ssh -o StrictHostKeyChecking=no -i ${keyfile} admin@ec2-18-143-65-82.ap-southeast-1.compute.amazonaws.com "docker rmi gnaig/mern-chat-app"'
		            sh 'ssh -o StrictHostKeyChecking=no -i ${keyfile} admin@ec2-18-143-65-82.ap-southeast-1.compute.amazonaws.com "docker run -p 80:8080 -e NODE_ENV=production -e MONGO_URI=${mongo_uri}"'
		        }
		    }
    }

	}

	post {
		always {
			sh 'docker logout'
		}
	}

}
