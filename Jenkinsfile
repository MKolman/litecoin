//define repository
def litecoin_repo = 'https://github.com/kantsuw/litecoin.git'


//define parameter 
properties([
  parameters([
    //branch of repository
    string(name: 'litecoin_repo_branch', description: 'Branch to build and deploy Litecoin from', defaultValue: 'master'),
    //image repo tag
    string(name: 'image_repo_tag', description: 'Full Docker image name with repository included.', defaultValue: 'kantsuw/litecoin'),
    //kube config
    string(name: 'kubeconfig', description: 'The name of the kubeconfig file in your Jenkins .kube directory', defaultValue: 'dev')
  ])
])

throttle([]) {
  node() {
    timestamps {
      try {

        git url: litecoin_repo, branch: params.litecoin_repo_branch
        //Build continer from docker file & push
        stage('Build') {
          sh """
            docker build -t ${params.image_repo_tag}:0.18.1 .
            docker push ${params.image_repo_tag}:0.18.1
          """
        }
        //Deploy to k8s cluster with kubectl
        stage('Deploy') {
          sh """
            kubectl --kubeconfig ~/.kube/${params.kubeconfig} apply -f statefulset.yaml
          """
        }
      } catch (ex) {
        currentBuild.result = 'FAILURE'
        //If failure echo failure
        sh """
          echo FAILURE
        """
      }

    }
  }
}
