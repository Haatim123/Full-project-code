# Monitoring and Logging in Kubernetes
Monitoring and logging are crucial for managing a Kubernetes cluster and its workloads. Here's a detailed breakdown of how to set up Prometheus, Grafana, and Fluentd for monitoring and logging.

**Prometheus & Grafana: Monitoring the Cluster**
Prometheus is a powerful monitoring and alerting toolkit that collects metrics from Kubernetes, while Grafana visualizes these metrics on dashboards.

**Step 1: Deploy Prometheus and Grafana with Helm**
Helm charts simplify the installation of complex applications like Prometheus and Grafana.

**Install Prometheus**
The kube-prometheus-stack chart from the prometheus-community repository bundles Prometheus, Alertmanager, and other monitoring components.

1. Add the Prometheus Helm repository:
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

2. Install Prometheus 
   helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   
   **Namespace:** Deploys to the monitoring namespace.
   **kube-prometheus-stack:** Includes Prometheus, Alertmanager, and pre-configured Grafana.

# Install Grafana
The grafana chart is used to deploy Grafana for creating dashboards.

1. Add the Grafana Helm repository:
  helm repo add grafana https://grafana.github.io/helm-charts
  helm repo update
2. Install Grafana:
  helm install grafana grafana/grafana --namespace monitoring
 After installation: 
 **1.The Grafana admin password can be retrieved with:**
 kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

 **2. Access Grafana using the service's NodePort or LoadBalancer.**

**Step 2: Configure Dashboards and Datasources**
1. Set up Prometheus as a data source in Grafana:
Login to Grafana (http://<grafana-ip>:<grafana-port>).
Navigate to Configuration → Data Sources → Add Data Source.
Select Prometheus and provide the Prometheus service URL (e.g., http://prometheus-server.monitoring.svc.cluster.local).

2. Import pre-built dashbaords: 
  Grafana offers many pre-configured dashboards in its marketplace.
  Navigate to Dashboard → Import and use IDs like 6417 (Kubernetes Cluster Monitoring).

# Logging with Fluentd: 
Fluentd is a log aggregator that collects logs from your Kubernetes pods and sends them to a central location like AWS CloudWatch.

**Step 1: Deploy Fluentd in Kubernetes**
1. Use Helm to deploy Fluentd:
   Add Fluentd Helm repository- 
   helm repo add fluent https://fluent.github.io/helm-charts
   helm repo update

   Install Fluentd-
   helm install fluentd fluent/fluentd --namespace logging --create-namespace

2. Configure Fluentd with a custom values.yaml to send logs to CloudWatch:
   aws:
  region: us-east-1
  access_key_id: <your-access-key-id>
  secret_access_key: <your-secret-access-key>

output:
  cloudwatch_logs:
    log_group_name: /kubernetes/cluster-logs
    log_stream_name_key: container_name
    auto_create_group: true

input:
  systemd_logs: true
  kubernetes_logs: true

**Install with:**
helm install fluentd fluent/fluentd --namespace logging -f values.yaml

**Step 2: Create AWS IAM Roles for Fluentd**
Fluentd requires permissions to send logs to CloudWatch. Create an IAM policy:

json: 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}

**Attach this policy to the IAM role associated with Fluentd pods.**

**Step 3: Verify Logs in CloudWatch**
1. Navigate to the CloudWatch Logs console in AWS.
2. Check the log group /kubernetes/cluster-logs for logs collected from Kubernetes pods.

**How It Works Together**
Prometheus scrapes metrics from Kubernetes objects, nodes, and applications.
Grafana visualizes these metrics for monitoring cluster health.
Fluentd collects logs from pods and sends them to AWS CloudWatch, providing centralized logging.
Together, these tools offer a complete observability solution for your Kubernetes cluster.
