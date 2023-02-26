#!/bin/bash
LANGUAGES=()
if [[ -f Makefile ]]; then
    LANGUAGE+=("c")
fi
if [[ -f CMakeLists.txt ]]; then
    LANGUAGE+=("cpp")
fi
if [[ -f app/pom.xml ]]; then
    LANGUAGE+=("java")
fi
if [[ -n $(find . -name '*.go') ]]; then
    LANGUAGE+=("go")
fi
if [[ -f Cargo.toml ]]; then
    LANGUAGE+=("rust")
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

source /google-cloud-sdk/path.bash.inc

image_name=$REGISTRY_HOST/whanos-${LANGUAGE[0]}/$1

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
    python3 /kubernetes/get_deployment.py $image_name $1
    cat deployment.yaml
    kubectl apply -f deployment.yaml
    echo "Deployment finished"
    echo "LoadBalancer details:"
    kubectl describe services $1-service
    exit 0
fi
