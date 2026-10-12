pipeline {
 agent any
 options {
  timestamps(); disableConcurrentBuilds()
 }
 environment {
  APIM_ENV = 'dev'; MI_DEPLOY_DIR = '/opt/wso2mi/repository/deployment/server/carbonapps'
 }
 stages {
  stage('Checkout') {
   steps {
    checkout scm
   }
  }
  stage('Validate sources') {
   steps {
    sh 'python3 -m unittest discover -s tests -v'
   }
  }
  stage('Build MI') {
   steps {
    dir('wso2-mi') {
     sh 'mvn -B clean install'
    }
   }
  }
  stage('Stage artifacts') {
   steps {
    sh 'test "$(find wso2-mi/integrations/target -maxdepth 1 -name "*.car" | wc -l)" -eq 1'; archiveArtifacts artifacts: 'wso2-mi/integrations/target/*.car', fingerprint: true
   }
  }
  stage('Deploy MI dev') {
   steps {
    sh 'set -eu; CAR=$(find wso2-mi/integrations/target -maxdepth 1 -name "*.car" | head -1); cp "$CAR" "$MI_DEPLOY_DIR/"'
   }
  }
  stage('Smoke MI dev') {
   steps {
    sh 'bash tests/smoke.sh'
   }
  }
  stage('Deploy APIM dev') {
   steps {
    withCredentials([usernamePassword(credentialsId: 'apim-dev', usernameVariable: 'APIM_USER', passwordVariable: 'APIM_PASS')]) {
     sh '''
        set -eu
        apictl login "$APIM_ENV" -u "$APIM_USER" -p "$APIM_PASS" -k
        for api in AccountsAPI CustomersAPI LoansAPI; do
          apictl import-api -f "apim-artifacts/$api" -e "$APIM_ENV" --update -k
        done
        '''
    }
   }
  }
  stage('Production gate') {
   when {
    branch 'main'
   } steps {
    input message: 'Promote validated release to production?', ok: 'Approve'
   }
  }
 }
 post {
  failure {
   echo 'Deployment failed; inspect the stage logs. Earlier deployments may require rollback.'
  }
 }
}