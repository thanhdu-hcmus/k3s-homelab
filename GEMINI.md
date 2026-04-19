# K3s Homelab Project
This project establishes a production-like Kubernetes homelab environment using K3s on VMware
Workstation, provisioned with Vagrant. It integrates a comprehensive set of DevOps and DevSecOps tools
to manage infrastructure and application deployments through GitOps principles.

## Project Overview
The primary goal of this project is to create a robust and automated Kubernetes homelab that mirrors a
production setup. Key features include:
*   **Virtual Machine Provisioning:** Automated setup of K3s cluster nodes (1 master, 2 workers) using
Vagrant and VMware Workstation.
*   **Kubernetes Cluster:** A lightweight K3s cluster configured with Flannel for networking.
*   **Infrastructure as Code (IaC):** Terraform manages the core Kubernetes platform components,
including namespaces, Argo CD, Sealed Secrets, and Kyverno.
*   **GitOps with Argo CD:** Argo CD is used as the central GitOps tool to manage applications across
multiple environments (`dev`, `staging`, `prod`) using Kustomize overlays.
*   **Secrets Management:** Sealed Secrets encrypts sensitive data directly into Git, ensuring secure
storage and deployment.
*   **DevSecOps Practices:** Kyverno enforces Kubernetes policies (e.g., Pod Security Standards), and
GitHub Actions include container image vulnerability scanning with Trivy.
*   **CI/CD Pipeline:** A GitHub Actions workflow automates the build, security scanning, and
promotion of application images, updating the GitOps repository to trigger Argo CD deployments.

## Building and Running
To set up and operate this homelab, follow these phases:
### Phase 1: Provision the VMs and K3s Cluster
1.  **Ensure Prerequisites:** Vagrant and VMware Workstation are installed on your host machine.
2.  **Start VMs:** Navigate to the project root and bring up the Vagrant VMs. The K3s cluster will be
automatically installed.
```
vagrant up
```
*This process will take some time as it downloads the base box, provisions the VMs, and installs
K3s. The master node will automatically generate and copy the `kubeconfig/k3s.yaml` file to your host
machine.*

3.  **Verify Cluster Connectivity:** Once `vagrant up` completes, you should be able to interact with
your K3s cluster.
```
kubectl --kubeconfig kubeconfig/k3s.yaml get nodes
```

### Phase 2: Apply Platform Components with Terraform

This phase deploys Argo CD, Sealed Secrets, Kyverno, and the environment namespaces to your K3s
cluster.

1.  **Initialize Terraform:**
 cd terraform
 terraform init
2.  **Apply Configuration:**
 terraform apply -auto-approve

### Phase 3: Finalize GitOps with Argo CD

1.  **Initialize Git Repository:** If not already done, initialize a Git repository in the project root
and push your code to a GitHub repository.
 git init
 git add .
 git commit -m "Initial homelab setup"
 git remote add origin https://github.com/YOUR_USERNAME/k3s-homelab.git # Replace with your repo URL
 git push -u origin main
2.  **Update Argo CD `repoURL`:** Edit `manifests/argocd/applications.yaml` and replace
`https://github.com/YOUR_USERNAME/k3s-homelab.git` with the actual URL of your GitHub repository.
3.  **Deploy Argo CD Applications:**
 kubectl apply -f ../manifests/argocd/applications.yaml --kubeconfig ../kubeconfig/k3s.yaml
    Argo CD will now begin syncing the `guestbook` application to your `dev`, `staging`, and `prod`
environments.

### Phase 4: Access Argo CD

1.  **Get Admin Password:**
 kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
2.  **Get Argo CD Server LoadBalancer IP:**
```
kubectl -n argocd get svc argocd-server
```
*Note: If MetalLB is not yet configured, the `argocd-server` service might show `<pending>` for its External IP. You might need to port-forward or configure MetalLB to access it externally.*

## Development Conventions
*   **GitOps Workflow:** All infrastructure and application changes are driven through Git.
Modifications to manifests in the `manifests/` directory will be automatically synchronized by Argo
CD.
*   **Kustomize Overlays:** Environment-specific configurations for applications are managed using
Kustomize overlays (`manifests/apps/<app>/overlays/<env>`).
*   **DevSecOps:**
    *   **Policy Enforcement:** Kyverno policies are installed to enforce security standards within
the cluster.
    *   **Vulnerability Scanning:** Container images are scanned with Trivy as part of the CI
pipeline.
*   **Secrets Management:** Sealed Secrets are used for managing sensitive information in Git. Do not
commit plaintext secrets.
*   **CI/CD:** The `.github/workflows/ci.yml` defines the continuous integration and deployment
process for applications.