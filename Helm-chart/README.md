 # Helm chart 
 When you run helm create myapp, Helm generates a basic scaffolding structure for your Helm chart. This structure helps you organize Kubernetes resources and make your deployments more modular, reusable, and manageable.

 # Benefits of Using Helm Charts
  **Parameterization:** Simplifies configuration through values.yaml.
  **Reusability:** Charts can be reused across environments (dev, staging, prod).
  **Versioning:** Helm tracks versions for easier rollback.
  **Simplified Updates:** You can easily upgrade applications using Helm.
  **Dependency Management:** Charts can include other charts as dependencies.

# Helm Chart Directory Structure
Here is what the generated structure looks like:

myapp/
├── Chart.yaml          # Metadata about the chart
├── values.yaml         # Default configuration values
├── charts/             # Directory for dependencies
├── templates/          # Kubernetes manifests (YAML files)
│   ├── deployment.yaml # Deployment resource template
│   ├── service.yaml    # Service resource template
│   ├── ingress.yaml    # Ingress resource template (optional)
│   ├── hpa.yaml        # Horizontal Pod Autoscaler (optional)
│   ├── configmap.yaml  # ConfigMaps for application config
│   ├── secrets.yaml    # Secrets (e.g., database credentials)
│   ├── _helpers.tpl    # Helper templates (reusable blocks)
│   └── NOTES.txt       # Instructions displayed after `helm install`
└── .helmignore         # Files to ignore when packaging the chart

# Key Files and Their Purpose
1. Chart.yaml:
   This file contains metadata about the Helm chart, such as its name, version, and description.
   Example:   
   apiVersion: v2
   name: myapp
   description: A Helm chart for deploying MyApp
   type: application
   version: 1.0.0
   appVersion: 1.0.0
2. values.yaml: 
   This file contains default configuartion values for the chart. Users can override these values using a custom values.yaml during installation.
   EX: 
   replicaCount: 2

image:
  repository: myapp
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80

3. templates/
This folder contains the Kubernetes resource manifests written as Helm templates. These YAML files can include placeholders ({{ }}) for dynamic values.
Example: deployment.yaml
Defines the application deployment, parameterized with values from values.yaml.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
          resources:
            {{- toYaml .Values.resources | nindent 12 }}

**Example: service.yaml**
Defines the Kubernetes Service to expose the application.
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
  selector:
    app: {{ .Chart.Name }}

**Example: ingress.yaml**
Defines the ingress rules for the application.
yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Chart.Name }}
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ $.Chart.Name }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
  tls:
    {{- range .Values.ingress.tls }}
    - secretName: {{ .secretName }}
      hosts:
        {{- range .hosts }}
        - {{ . }}
        {{- end }}
    {{- end }}
{{- end }}

4. NOTES.txt
Displays helpful notes or instructions after deploying the chart.
Example:
Thank you for installing {{ .Chart.Name }}!

Your application is running at:
  http://{{ .Values.ingress.hosts[0].host }}

# How to Deploy Using the Chart
1. Package the Chart: 
   helm package myapp

2. Install the Chart:   
   helm install myapp ./myapp

3. Override Default Values (Optional): Create a custom values.yaml file to override defaults:
  replicaCount: 3
  image:
   tag: v1.1.0
  ingress:
   enabled: true
   hosts:
     - host: custom.example.com

   Install using the custom values: 
   helm install myapp ./myapp -f custom-values.yaml

4. Upgrade the Chart: To upgrade the release with new values or templates:
   helm upgrade myapp ./myapp

5. Uninstall the Chart:
   helm uninstall myapp
 
 

