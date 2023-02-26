# Whanos YML Explain

## Exemple of whanos.yml file

```yaml
deployment:
  replicas: 3
  resources:
    limits:
      memory: "128M"
    requests:
      memory: "64M"
  ports:
    - 3000
```

This file is used to configure the deployment of your project.  

**Replicas**:  
- Number of replicas to have (default: 1; 2 replicas means that 2 instances of the resulting pod must be running at the same time in the cluster);

**Ressources**:
- The ressources are the limits or the requirements of your project. There is not default values ([ref](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container))

**Ports**:
- An integer list of ports needed by the container to be forwarded to it. Default: no ports forwarded. (Actually only one port is supported)

