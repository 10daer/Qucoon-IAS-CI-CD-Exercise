# Tesa Lab Infrastructure Setup Instructions

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **SSH key pair** generated
4. **GitHub repository** for your website code

## Step 1: Prepare SSH Key Pair

```bash
# Generate SSH key pair if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# The public key will be used in Terraform
# The private key will be used in GitHub Actions
```

## Step 2: Deploy Infrastructure with Terraform

1. **Save the Terraform configuration** to `main.tf`

2. **Initialize and apply Terraform**:

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

3. **Note the outputs** after successful deployment:
   - `instance_public_ip`: Your server's public IP
   - `website_url`: URL to access your website
   - `ssh_command`: Command to SSH into your server

## Step 3: Setup GitHub Repository

1. **Create a new GitHub repository** for your website

2. **Add the sample website files**:

   - Create `index.html` with the provided HTML content
   - Create `styles.css` with the provided CSS content
   - Commit and push to your repository

3. **Create the GitHub Actions workflow**:
   - Create `.github/workflows/deploy.yml` with the provided workflow content

## Step 4: Configure GitHub Secrets

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

1. **EC2_SSH_PRIVATE_KEY**: Your private SSH key content

   ```bash
   # Copy your private key content
   cat ~/.ssh/id_rsa
   ```

2. **EC2_HOST**: Your EC2 instance public IP (from Terraform output)

## Step 5: Configure Server for Deployment

SSH into your server and set up the deployment user:

```bash
# SSH into your server
ssh -i ~/.ssh/id_rsa ubuntu@YOUR_SERVER_IP

# Add your public key to authorized_keys for the deploy user
sudo mkdir -p /home/deploy/.ssh
echo "YOUR_PUBLIC_KEY_CONTENT" | sudo tee /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
```

## Step 6: Test the Deployment

1. **Push code to your main branch** - this will trigger the GitHub Actions workflow

2. **Monitor the deployment** in GitHub Actions tab

3. **Access your website** using the public IP or domain

## File Structure

Your GitHub repository should look like this:

```
your-repo/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── index.html
├── styles.css
└── README.md
```

## Customization Options

### Terraform Variables

You can customize the Terraform deployment by modifying these variables in `main.tf`:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  default     = "10.0.1.0/24"
}
```

### Security Considerations

1. **Restrict SSH access** by updating the security group to allow SSH only from your IP:

   ```hcl
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP
   }
   ```

2. **Use IAM roles** instead of hardcoded credentials

3. **Enable CloudTrail** for audit logging

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**:

   - Check security group allows SSH (port 22)
   - Verify SSH key permissions (600 for private key)
   - Ensure instance is in a public subnet with internet gateway

2. **Website Not Accessible**:

   - Check security group allows HTTP (port 80)
   - Verify nginx is running: `sudo systemctl status nginx`
   - Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`

3. **GitHub Actions Deployment Failed**:
   - Verify GitHub secrets are set correctly
   - Check SSH key format (no extra spaces or characters)
   - Ensure deploy user has proper permissions

### Useful Commands

```bash
# Check nginx status
sudo systemctl status nginx

# Reload nginx configuration
sudo systemctl reload nginx

# Check website files
ls -la /var/www/html/website/

# View deployment logs
sudo tail -f /var/log/nginx/access.log
```
