# Gitlab Kubernetes Integration

Gitlab Kubernetes Agent Server does not support CE version, so let's use Gitlab Runner.


## Install Gitlab Runner in Kubernetes

1. Go to Gitlab admin area `Overview -> Runners`

    Get the Gitlab URL and Runner registration token.

2. Install Gitlab Runner Helm chart

    Helm chart: https://gitlab.com/gitlab-org/charts/gitlab-runner.git

    values.yaml:
    ```
    gitlabUrl: https://gitlab.example.com/
    runnerRegistrationToken: "Ptb16r9Amwhqom_44oAU"
    runners:
      config: |
        [[runners]]
          [runners.kubernetes]
            namespace = "{{.Release.Namespace}}"
            image = "docker.io/library/ubuntu:20.04" # this image will be used when a job has no `image` specified
            privileged = true
          [[runners.kubernetes.volumes.empty_dir]]
            name = "docker-certs"
            mount_path = "/certs"
            medium = "Memory"
    ```

3. Gitlab CI yaml file

    In following example, there will be three containers in the job pod:
    * docker:dind service container, provides the docker engine throught tcp 2376
    * docker:latest container, runs the build jobs
    * gitlab-runner-helper:x86_64-VERSION container, runs ?

    ```
    variables:
      DOCKER_HOST: tcp://localhost:2376/
      DOCKER_TLS_CERTDIR: "/certs"
      DOCKER_TLS_VERIFY: 1
      DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

    build-job:
      stage: build
      image: docker.io/library/docker:latest
      services:
        - docker.io/library/docker:dind
      before_script:
        - docker info
      script:
        - docker build -t image-name .
        - echo "Hello, $GITLAB_USER_LOGIN!"

    test-job1:
      stage: test
      script:
        - echo "This job tests something"

    test-job2:
      stage: test
      script:
        - echo "This job tests something, but takes more time than test-job1."
        - echo "After the echo commands complete, it runs the sleep command for 20 seconds"
        - echo "which simulates a test that runs 20 seconds longer than test-job1"
        - sleep 20

    deploy-prod:
      stage: deploy
      script:
        - echo "This job deploys something from the $CI_COMMIT_BRANCH branch."
    ```
