folder("Whanos Base Images") {
  description("Whanos Base Images")
}

folder("Projects") {
  description("Projects")
}

languages = ["c", "java", "javascript", "python", "befunge", "cpp", "go", "rust"]

languages.each{ language -> 
  freeStyleJob("Whanos Base Images/whanos-$language") {
    steps {
      shell("docker build -t whanos-$language:latest -f /images/$language/Dockerfile.base /images/$language")
    }
  }
}

freeStyleJob("Whanos Base Images/Build all base images") {
    publishers {
        downstream(
            languages.collect { language -> "Whanos Base Images/whanos-$language" } // using collect because downstream need a new list
        )
    }
}

freeStyleJob("google-cloud-artifacts-auth") {
  parameters{
    stringParam("GOOGLE_PROJECT_ID", null, "Google project id")
    fileParam("gcloud-service-account-key.json", "Account service key file")
    stringParam("GCLOUD_KUBERNETE_CLUSTER_NAME", null, "The name of your GKE cluster")
    stringParam("GCLOUD_KUBERNETE_CLUSTER_LOCATION", null, "Location of the cluster")
    stringParam("GOOGLE_ARTIFACT_REGISTRY_ZONE", "europe-west9-docker", "Google artifact registry zone")
  }
  steps {
    shell("cat gcloud-service-account-key.json | docker login -u _json_key --password-stdin https://\$GOOGLE_ARTIFACT_REGISTRY_ZONE.pkg.dev")
    shell("/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=gcloud-service-account-key.json")
    shell("/google-cloud-sdk/bin/gcloud config set project \$GOOGLE_PROJECT_ID")
    shell("/google-cloud-sdk/bin/gcloud container clusters get-credentials \$GCLOUD_KUBERNETE_CLUSTER_NAME --zone \$GCLOUD_KUBERNETE_CLUSTER_LOCATION")
  }
}

freeStyleJob("link-project") {
  parameters{
    stringParam("GIT_URL", null, "Git repository url")
    stringParam("DISPLAY_NAME", null, "Display name")
  }
  steps {
    dsl {
      text('''
              freeStyleJob("Projects/$DISPLAY_NAME") {
                scm {
                  git {
                    remote {
                      name("origin")
                      url("$GIT_URL")
                    }
                  }
                }
                triggers {
                  scm("* * * * *")
                }
                wrappers {
                  preBuildCleanup()
                }
                steps {
                  shell("/jenkins/build.sh \\"$DISPLAY_NAME\\"")
                }
              }

      ''')
    }
  }
}