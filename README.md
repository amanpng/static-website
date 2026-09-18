# AWS Static Website Deployment (Terraform + Ansible)

## 📌 Project Description
This project automates the provisioning of AWS infrastructure and the deployment of a static website using **Infrastructure as Code (IaC)**. 
- **Terraform** provisions an AWS EC2 instance (`t3.micro`), configures a security group for HTTP/SSH access, attaches an SSH key pair, and dynamically creates an Ansible inventory.
- **Ansible** runs a configuration management playbook, installing the Nginx web server and deploying the static website files (`HTML` and `CSS`) directly to the newly provisioned EC2 instance.

## 🏗️ Architecture & Project Structure
- `terraform/`: Contains Terraform configuration scripts for provisioning AWS resources (`main.tf`, `outputs.tf`, `variables.tf`). It leverages a local template file (`inventory.tpl`) to dynamically generate an Ansible inventory upon completion.
- `ansible/`: Contains the master playbook (`deploy.yml`) to perform system updates, install the Nginx web server, and copy static website assets.
- `website/`: Contains the source code of the static website (`index.html`, `style.css`).

## 🛠️ Prerequisites
Ensure that the following dependencies are installed on your local machine before proceeding:
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (>= 2.9)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (configured with appropriate IAM permissions)
- OpenSSH (to generate valid SSH key pairs)

## 🔐 Environment Variables & Setup
To allow Terraform and Ansible to authenticate with AWS and access the target nodes securely, configure these environment variables on your system:

### 1. AWS Credentials
Set the AWS CLI credentials directly in your terminal, or configure them comprehensively using `aws configure`.
```bash
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="ap-south-1"  # Check main.tf if you decide to change default provider region
```

### 2. Ansible Host Key Checking (Optional)
To avoid manual interactive confirmations while connecting to newly spawned EC2 instances during development, you can temporarily disable SSH host key checking:
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

## 🚀 Installation & Usage Steps

### Step 1: Generate an SSH Key Pair
Create a dedicated SSH key pair for securely accessing the EC2 instance (this must match the default path expected by Terraform/Ansible). Ensure proper permissions are assigned to the private key.
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-ansible-key -N ""
chmod 400 ~/.ssh/terraform-ansible-key
```

### Step 2: Provision Infrastructure using Terraform
Navigate to the `terraform` directory, initialize the provider plugins, verify the plan, and apply the infrastructure configuration.
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```
*Note: Once successfully applied, Terraform automatically creates a dynamic `inventory` file inside the `ansible/` folder populated with the new EC2 public IP.*

### Step 3: Deploy the Website using Ansible
Navigate to the `ansible` directory and run the deployment playbook over the updated inventory.
```bash
cd ../ansible
ansible-playbook -i inventory deploy.yml
```

### Step 4: Access your Live Website
Retrieve the public IP address obtained from the Terraform outputs. Open your graphical web browser and navigate directly to:
```text
http://<YOUR_EC2_PUBLIC_IP>
```
You should see: **"Hello from AWS EC2 🚀 Terraform + Ansible"**.

## 🧹 Teardown / Cleanup
To avoid incurring unwanted AWS charges, cleanly destroy the infrastructure when you are done testing.
```bash
cd ../terraform
terraform destroy -auto-approve
```

## 📋 Modifying Configuration (Terraform Variables)
If you wish to change the SSH key path or explore other local variable options, you can override the Terraform configurations.
The default SSH private key path is mapped in `terraform/variables.tf`:
```terraform
ssh_private_key_path = "~/.ssh/terraform-ansible-key"
```
You can override this without editing the original files by passing `-var` during the `terraform apply` step:
```bash
terraform apply -var="ssh_private_key_path=~/.ssh/your-custom-key"
```
