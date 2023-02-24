#!/bin/bash
LANGUAGES=()
if [[ -f Makefile ]]; then
    LANGUAGE+=("c")
fi
if [[ -f app/pom.xml ]]; then
    LANGUAGE+=("java")
fi
if [[ -f package.json ]]; then
    LANGUAGE+=("javascript")
fi
if [[ -f requirements.txt ]]; then
    LANGUAGE+=("python")
fi
if [[ -f app/main.bf ]]; then
    LANGUAGE+=("befunge")
fi

if [[ ${#LANGUAGE[@]} == 0 ]]; then
    echo "Error: no language found"
    exit 1
fi
if [[ ${#LANGUAGE[@]} != 1 ]]; then
    echo "Error: more than 1 language detected"
    exit 1
fi

echo "Language found : ${LANGUAGE[0]}"

image_name=europe-west9-docker.pkg.dev/whanos-377316/whanos-${LANGUAGE[0]}/$1

if [[ -f Dockerfile ]]; then
    docker build . -t $image_name
else
    docker build . -t $image_name -f /images/${LANGUAGE[0]}/Dockerfile.standalone
fi

docker push $image_name
#ret_value=$(docker push $image_name)

#if [[ $ret_value != 0 ]]; then    
#    echo "Error: docker push failed"
#    exit 1
#fi

if [[ -f whanos.yml ]]; then
    echo "whanos.yml found"
    echo "Deployment started ..."
    gcloud container clusters get-credentials cluster-1 --zone europe-west8-a --project whanos-377316
    python3 /kubernetes/get_deployment.py $image_name $1
    cat deployment.yaml
    kubectl apply -f deployment.yaml
    exit 0
fi
