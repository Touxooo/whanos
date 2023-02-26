import yaml
import sys
import os

class Whanos:
    def __init__(self):
        self.replicas: int = 1
        self.port: list[int] = []
        self.limitscpu: str = None
        self.limitsmemory: str = None
        self.requestscpu: str = None
        self.requestsmemory: str = None
        self.haslimits = self.limitscpu or self.limitsmemory
        self.hasrequests = self.requestscpu or self.requestsmemory
        self.ressources = None
    
    def update_has(self):
        self.haslimits = bool(self.limitscpu or self.limitsmemory)
        self.hasrequests = bool(self.requestscpu or self.requestsmemory)


    def parse_whanos(self, dico, actual_key: str = ""):
        for key, value in dico.items():
            if isinstance(value, dict):
                self.parse_whanos(value, key)
            else:
                if str(actual_key + key) in [attr for attr in dir(self) if not callable(getattr(self, attr)) and not attr.startswith("__")]:
                    setattr(self, str(actual_key + key), value)
                elif key == "replicas":
                    self.replicas = int(value)
                elif key == "ports":
                    for i in value:
                        self.port.append(int(i))
    
    def add_ressources(self):
        dico: dict = yaml.safe_load("""
    limits:
      memory: "128M"
      cpu: "128M"
    requests:
      memory: "64M"
      cpu: "128M"
""")
        if self.haslimits:
            if self.limitscpu:
                dico["limits"]["cpu"] = self.limitscpu
            else:
                del dico["limits"]["cpu"]
            if self.limitsmemory:
                dico["limits"]["memory"] = self.limitsmemory
            else:
                del dico["limits"]["memory"]
        else:
            del dico["limits"]
        if self.hasrequests:
            if self.requestscpu:
                dico["requests"]["cpu"] = self.requestscpu
            else:
                del dico["requests"]["cpu"]
            if  self.requestsmemory:
                dico["requests"]["memory"] = self.requestsmemory
            else:
                del dico["requests"]["memory"]
        else:
            del dico["requests"]
        self.ressources = dico


image: str = sys.argv[1]
project_name: str = sys.argv[2]

with open("/kubernetes/deployment_template.yaml", "r") as f:
    deployment_f = yaml.safe_load(f)

with open("/kubernetes/service_template.yaml", "r") as f:
    service_f = yaml.safe_load(f)

with open("whanos.yml", "r") as f:
    whanos_f = yaml.safe_load(f)

deployment_f["spec"]["template"]["spec"]["containers"][0]["image"] = image

whanos = Whanos()

whanos.parse_whanos(whanos_f)
whanos.update_has()
if whanos.haslimits or whanos.hasrequests:
    whanos.add_ressources()
    deployment_f["spec"]["template"]["spec"]["containers"][0]["resources"] = whanos.ressources
if whanos.replicas:
    deployment_f["spec"]["replicas"] = whanos.replicas
if len(whanos.port) > 0:
    for i in range(len(whanos.port)):
        deployment_f["spec"]["template"]["spec"]["containers"][0]["ports"][i]["containerPort"] = whanos.port[i]
        service_f["spec"]["ports"][i]["port"] = whanos.port[i]
        service_f["spec"]["ports"][i]["targetPort"] = whanos.port[i]
else:
    del deployment_f["spec"]["template"]["spec"]["containers"][0]["ports"]
data:str = yaml.safe_dump(deployment_f) + "---\n" + yaml.safe_dump(service_f) if len(whanos.port) > 0 else yaml.safe_dump(deployment_f)
data = data.replace("whanos-name", project_name)
deploy = open("deployment.yaml", "w")
print(data, file=deploy)
deploy.close()