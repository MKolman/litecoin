> :information_source: This repo contains code for the "Kraken DevOps Test" as the first step of my interview process. Repo is forked from https://github.com/kantsuw/litecoin with minor adjustments

# Litecoin 0.18.1 in Docker
This repository contains everything that you need to run Litecoin in Docker and Kubernetes with a simple Jenkins Pipeline script.

## Jenkins Server Requirements
- Docker CLI
- kubectl
- kubeconfig
  - separated config for your cluster must be located in ~/.kube/ directory of your Jenkins server (if you are using single kubeconfig you need to edit [Jenkinsfile](https://github.com/mkolman/litecoin/blob/master/Jenkinsfile#L27) addinf `--context NAME_OF_CONTEXT` in this repository

## Dockerfile
To help with faster set up in Kubernetes we use multistage docker build. In the first stage Litecoin and all its dependencies are installed, the package's SHA256 sum is verified and the package is uncompressed.

Second stage just copies over the extracted package and ensures they are owned by a non-privileged user named `litecoin`. Finally Litecoin daemon process is started as the user `litecoin`.

Build it on your computer - `docker build -t litecoin:0.18.1 .`

## Kubernetes config
Assumptions of `statefulset.yaml`
- There is no namespace `litecoin`
- `storageClassName: standard` exists

Additional information
- Using `runAsUser` and `fsGroup` to ensure that I will run with the same user as the one I've created in the Dockerfile
- `dnsConfig` - Adding it always after a huge outage of CoreDNS
- `tolerations` - I am running it in GCP on preemptible nodes
- `resources` - 256MB memory will be enough for Litecoin not in use :)

## Jenkinsfile
This is a very simple Jenkinsfile using Groovy DSL. You need to specify:
- repository
- branch
- full image name (change USERNAME with yours) 
  - `USERNAME/litecoin` - for docker hub
  - `gcr.io/USERNAME/litecoin` for gcp

Please read the Jenkins Server Requirements section for additional information about the kubeconfig customizations.

# Note to reviewers
This is my first ever interaction with Kubernetes. In my role at Google I work closely with our internal container scheduling system - Borg. It is what inspired Kubernetes but they still have different config language and terminology.

I already bought myself a small server rack stand and to set up a few machines at home in order to get some first hand experience running Kubernetes. 

I have never used Terraform before so I skipped that task.

I've opted to use an existing solution for this problem, because solved problems don't need re-solving and existing code usually solved problems you didn't think of.

Two major improvements I made to the code are
* making `shasum.py` more readable and cleaner,
* including sha256 signature file in the repo instead of downloading it for security reasons.
  * Downloading the checksum protects us from file corruption during package download, but doesn't protect us from an attack if litecoin.org is compromised.