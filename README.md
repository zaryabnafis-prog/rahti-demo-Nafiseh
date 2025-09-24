# CSC Rahti Demo Application

This is a demonstration application for CSC's Rahti container platform. The application is a Python Flask-based web application optimized to run in OpenShift/OKD environments.

## 📖 What This Application Does

### Application Overview

This demo application is a **complete containerized web application** that demonstrates best practices for deploying Python applications on CSC's Rahti platform. It serves as both a learning tool and a starting template for your own projects.

### Core Functionality

**Web Interface:**
- **Interactive Dashboard** - A responsive web page displaying real-time system information
- **System Monitoring** - Shows hostname, platform details, Python version, and memory usage
- **API Testing Interface** - Built-in tools to test REST API endpoints directly from the browser
- **Feature Showcase** - Demonstrates all application capabilities in an easy-to-use interface

**REST API:**
- **Health Monitoring** - Kubernetes-compatible health and readiness checks
- **System Information** - JSON endpoints providing detailed system metrics
- **Sample Data API** - Demonstrates typical API data exchange patterns
- **Error Handling** - Proper HTTP status codes and error responses

**Container Features:**
- **Production-Ready** - Follows security best practices and OpenShift requirements
- **Auto-Scaling** - Automatically adjusts to traffic demands using Horizontal Pod Autoscaler
- **Persistent Storage** - Supports data persistence across container restarts
- **Monitoring Integration** - Built-in logging and health checks for operations teams

### How It Works

#### 1. Application Architecture

The application follows a **layered architecture**:

```
┌─────────────────────────────────────┐
│           Web Browser               │ ← User Interface
├─────────────────────────────────────┤
│         OpenShift Route             │ ← HTTPS Load Balancer
├─────────────────────────────────────┤
│      Kubernetes Service            │ ← Internal Load Balancer  
├─────────────────────────────────────┤
│     Flask Application Pods         │ ← Application Logic
├─────────────────────────────────────┤
│    Persistent Volume Claims        │ ← Data Storage
└─────────────────────────────────────┘
```

#### 2. Request Flow

1. **User Request** → Browser sends HTTP request
2. **Route Processing** → OpenShift Route terminates SSL and forwards to Service
3. **Load Balancing** → Kubernetes Service distributes load across healthy pods
4. **Application Processing** → Flask app processes request and generates response
5. **Response Delivery** → JSON/HTML response sent back through the chain

#### 3. Container Lifecycle

**Build Phase:**
```python
# Dockerfile creates optimized container image
FROM python:3.11-slim
COPY requirements.txt app.py ./
RUN pip install --no-cache-dir -r requirements.txt
USER 1001  # Non-root security
EXPOSE 8080
CMD ["python", "app.py"]
```

**Runtime Phase:**
```python
# app.py starts with environment configuration
port = int(os.environ.get('PORT', 8080))
app.run(host='0.0.0.0', port=port, debug=False)
```

**Scaling Phase:**
- HPA monitors CPU/memory usage
- Automatically creates/destroys pods based on demand
- Maintains 1-5 replicas for optimal performance

#### 4. Key Components Explained

**Flask Application (`app.py`):**
- **Main Server** - Handles HTTP requests and responses
- **Template Rendering** - Serves HTML pages with dynamic content
- **API Endpoints** - Provides JSON data for programmatic access
- **Error Handling** - Graceful error pages and logging
- **Health Checks** - Kubernetes integration for automated management

**Web Templates:**
- **`index.html`** - Main dashboard with system info and API testing
- **`error.html`** - User-friendly error pages with proper styling
- **Responsive Design** - Works on desktop, tablet, and mobile devices

**Kubernetes Manifests:**
- **`deployment.yaml`** - Pod configuration, scaling, and health checks
- **`service.yaml`** - Internal networking and external route exposure
- **`configmap.yaml`** - Configuration data and environment variables
- **`hpa.yaml`** - Automatic scaling based on resource usage
- **`storage-and-network.yaml`** - Persistent storage and network policies

#### 5. Security Implementation

**Container Security:**
```dockerfile
# Run as non-root user (required by OpenShift)
USER 1001
# Remove package manager to reduce attack surface
RUN apt-get remove -y apt
# Use minimal base image
FROM python:3.11-slim
```

**Application Security:**
```python
# Secure configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'default-key')
# Bind to all interfaces for container networking
app.run(host='0.0.0.0', port=port)
# Structured logging for security monitoring
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
```

**Kubernetes Security:**
```yaml
# Security context in deployment
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

### Real-World Use Cases

This application demonstrates patterns you'll use in production:

1. **Microservices** - Shows how to containerize a web service
2. **API Development** - REST endpoints for data exchange
3. **Health Monitoring** - Integration with Kubernetes health checks
4. **Auto-Scaling** - Handling variable traffic loads
5. **Configuration Management** - Environment-based configuration
6. **Logging & Monitoring** - Structured logging for operations
7. **Security Compliance** - Following OpenShift security requirements

### Learning Outcomes

After deploying and exploring this application, you'll understand:

- **Container Deployment** - How to deploy applications to OpenShift/Kubernetes
- **Service Networking** - How services communicate in a cluster
- **Auto-Scaling** - How applications automatically handle load
- **Health Monitoring** - How Kubernetes monitors application health
- **Configuration Management** - How to manage app configuration in containers
- **Security Best Practices** - How to run secure containers in production

## 🚀 Features

### Core Features Explained

- **Flask web application** - Lightweight Python web framework that provides:
  - Simple HTTP server with HTML templates
  - RESTful API endpoints for data exchange
  - Built-in development server and debugging tools
  
- **Rahti compatible** - Specifically optimized for CSC's OpenShift-based platform:
  - Uses OpenShift-compatible security contexts
  - Follows CSC's container image requirements
  - Supports OpenShift's automated builds and deployments
  
- **Security** - Production-ready security features:
  - Runs as non-root user (UID 1001) to prevent privilege escalation
  - Supports read-only root filesystem for enhanced security
  - Uses secure default settings and removes unnecessary packages
  
- **Health checks** - Kubernetes-native monitoring endpoints:
  - `/health` - Liveness probe to restart unhealthy containers
  - `/ready` - Readiness probe to control traffic routing
  - Enables automatic recovery and zero-downtime deployments
  
- **Automatic scaling** - HPA (Horizontal Pod Autoscaler) dynamically adjusts replicas:
  - Monitors CPU usage (scales at 70% threshold)
  - Monitors memory usage (scales at 80% threshold)
  - Automatically scales from 1 to 5 pods based on demand
  
- **Persistent storage** - Data persistence across pod restarts:
  - 1GB PersistentVolumeClaim for application data
  - ReadWriteOnce access mode for single-pod access
  - Survives container restarts and redeployments
  
- **Logging** - Comprehensive application monitoring:
  - Structured JSON logging for better parsing
  - Request/response logging for debugging
  - Error tracking and performance monitoring

## 📋 Requirements

### System Requirements

**All platforms:**
- CSC account and access to Rahti platform
- Internet connection
- Git (for cloning the repository)

**For deployment:**
- [OpenShift CLI (oc)](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)

**For local development:**
- Python 3.9+ 
- Docker (optional, for container testing)

### Platform-Specific Setup

#### Windows
```powershell
# Install OpenShift CLI
# Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/
# Extract oc.exe to a folder in your PATH, or:
winget install RedHat.OpenShiftCLI

# Install Python (if not installed)
winget install Python.Python.3.11

# Install Git (if not installed)
winget install Git.Git

# Verify installations
oc version
python --version
git --version
```

#### Linux (Ubuntu/Debian)
```bash
# Install OpenShift CLI
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar xzf -
sudo mv oc /usr/local/bin/
sudo chmod +x /usr/local/bin/oc

# Install Python and pip
sudo apt update
sudo apt install python3 python3-pip python3-venv git

# Verify installations
oc version
python3 --version
git --version
```

#### Linux (CentOS/RHEL/Fedora)
```bash
# Install OpenShift CLI
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar xzf -
sudo mv oc /usr/local/bin/
sudo chmod +x /usr/local/bin/oc

# Install Python and development tools
sudo dnf install python3 python3-pip git

# Verify installations
oc version
python3 --version
git --version
```

#### macOS
```bash
# Install OpenShift CLI using Homebrew
brew install openshift-cli

# Install Python (if not installed)
brew install python

# Verify installations
oc version
python3 --version
git --version
```

## 🏗️ Structure

```
csc-rahti-demo/
├── app.py                 # Main application
├── Dockerfile            # Container image definition
├── requirements.txt      # Python dependencies
├── deploy.sh            # Deployment script
├── templates/           # Flask templates
│   ├── index.html       # Home page
│   └── error.html       # Error page
└── k8s/                 # Kubernetes manifests
    ├── deployment.yaml  # Deployment configuration
    ├── service.yaml     # Service and Route
    ├── configmap.yaml   # ConfigMap and Secret
    ├── hpa.yaml         # Horizontal Pod Autoscaler
    └── storage-and-network.yaml  # Storage and Network policies
```

## 🚀 Getting Started

### Option 1: Fork the Repository (Recommended for Students)

**This creates your own copy on GitHub that you can modify and push changes to:**

1. **Fork on GitHub:**
   - Go to: https://github.com/Vikke82/csc-rahti-demo
   - Click the **"Fork"** button in the top-right corner
   - This creates a copy under your GitHub account: `https://github.com/YOUR-USERNAME/csc-rahti-demo`

2. **Clone your fork:**
   ```bash
   # Replace YOUR-USERNAME with your actual GitHub username
   git clone https://github.com/YOUR-USERNAME/csc-rahti-demo.git
   cd csc-rahti-demo
   ```

3. **Set up remotes (optional - for keeping up with updates):**
   ```bash
   # Add the original repository as "upstream"
   git remote add upstream https://github.com/Vikke82/csc-rahti-demo.git
   
   # Verify remotes
   git remote -v
   # Should show:
   # origin    https://github.com/YOUR-USERNAME/csc-rahti-demo.git (fetch)
   # origin    https://github.com/YOUR-USERNAME/csc-rahti-demo.git (push)
   # upstream  https://github.com/Vikke82/csc-rahti-demo.git (fetch)
   # upstream  https://github.com/Vikke82/csc-rahti-demo.git (push)
   ```

### Option 2: Direct Clone (Read-Only)

**For quick testing - you can't push changes back:**

```bash
git clone https://github.com/Vikke82/csc-rahti-demo.git
cd csc-rahti-demo
```

### Option 3: Download ZIP

**No Git required - download and extract:**

1. Go to: https://github.com/Vikke82/csc-rahti-demo
2. Click **"Code"** → **"Download ZIP"**
3. Extract the ZIP file to your desired location

## 🔄 Working with Your Own Copy

### Making Changes and Pushing

**After forking (Option 1), you can make changes and save them:**

```bash
# Make your changes to any files
# For example, edit app.py, templates, or add new features

# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "Add my custom feature"

# Push to your GitHub repository
git push origin main
```

### Keeping Your Fork Updated

**To get latest changes from the original repository:**

```bash
# Fetch latest changes from upstream
git fetch upstream

# Merge changes into your main branch
git checkout main
git merge upstream/main

# Push updated main to your fork
git push origin main
```

### Creating Your Own GitHub Repository

**If you want to start completely fresh:**

1. **Create new repository on GitHub:**
   - Go to: https://github.com/new
   - Repository name: `my-rahti-app` (or any name you prefer)
   - Description: `My CSC Rahti application based on demo`
   - Choose Public or Private
   - **Don't** initialize with README (we'll use the existing one)

2. **Clone the demo and change remote:**
   ```bash
   # Clone the demo
   git clone https://github.com/Vikke82/csc-rahti-demo.git my-rahti-app
   cd my-rahti-app
   
   # Remove original remote
   git remote remove origin
   
   # Add your new repository as origin
   git remote add origin https://github.com/YOUR-USERNAME/my-rahti-app.git
   
   # Push to your new repository
   git push -u origin main
   ```

3. **Customize for your project:**
   ```bash
   # Update README.md with your project details
   # Modify app.py for your specific needs
   # Change application name in k8s/ manifests
   # Update deploy scripts if needed
   
   # Commit your customizations
   git add .
   git commit -m "Customize application for my project"
   git push origin main
   ```

## 📚 Student Workflow Example

**Here's a typical workflow for students:**

### 1. Initial Setup
```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/csc-rahti-demo.git
cd csc-rahti-demo

# Test locally first
pip install -r requirements.txt
python app.py
# Visit http://localhost:8080
```

### 2. Deploy to CSC Rahti
```bash
# Login to CSC Rahti
oc login https://api.2.rahti.csc.fi:6443

# Create your project (use your CSC project number)
oc new-project my-student-project --description="csc_project: YOUR_NUMBER"

# Deploy the application
chmod +x deploy.sh  # Linux/macOS
./deploy.sh deploy

# Windows users:
# deploy.bat deploy
```

### 3. Make Customizations
```bash
# Edit application files
# For example, change the welcome message in app.py:
# 'message': 'Welcome to [Your Name]\'s Rahti Demo!'

# Update templates/index.html with your content
# Modify CSS styling, add new features, etc.

# Test locally
python app.py

# Commit changes
git add .
git commit -m "Customize welcome message and styling"
git push origin main
```

### 4. Update Deployment
```bash
# Rebuild and deploy updated application
oc start-build csc-rahti-demo --from-dir=. --follow

# Or use the deploy script
./deploy.sh deploy
```

### 5. Share Your Work
```bash
# Your GitHub repository: https://github.com/YOUR-USERNAME/csc-rahti-demo
# Your deployed app: Get URL with: oc get route csc-rahti-demo-route -o jsonpath='{.spec.host}'
# Share both links in your assignment submission
```

## 🎯 Assignment Ideas for Students

**Students can extend this demo by:**

1. **Add a Database:**
   - Deploy PostgreSQL or MySQL
   - Create data models
   - Add CRUD operations

2. **Implement Authentication:**
   - User registration/login
   - Session management
   - Protected routes

3. **Add Frontend Framework:**
   - React/Vue.js frontend
   - API-only backend
   - Modern SPA architecture

4. **Monitoring & Logging:**
   - Add Prometheus metrics
   - Implement structured logging
   - Create custom dashboards

5. **CI/CD Pipeline:**
   - GitHub Actions
   - Automated testing
   - Automatic deployment

6. **Custom Features:**
   - File upload/download
   - Real-time chat (WebSocket)
   - External API integration

## 🚀 Deployment to Rahti

### Step-by-Step Instructions

#### 1. Clone and prepare the repository

**Windows (PowerShell):**
```powershell
# Clone the repository
git clone https://github.com/Vikke82/csc-rahti-demo.git
cd csc-rahti-demo

# Make deploy script executable (not needed on Windows)
# The deploy.bat file is used instead
```

**Linux/macOS:**
```bash
# Clone the repository
git clone https://github.com/Vikke82/csc-rahti-demo.git
cd csc-rahti-demo

# Make deploy script executable
chmod +x deploy.sh
```

#### 2. Login to CSC Rahti

**All platforms:**
```bash
# Method 1: Direct API login
oc login https://api.2.rahti.csc.fi:6443

# Method 2: Get login command from web console (Recommended)
# 1. Go to https://rahti.csc.fi/
# 2. Login with your CSC credentials
# 3. Click your username in top-right corner
# 4. Select "Copy login command"
# 5. Paste the command in your terminal
```

#### 3. Create a new project (if needed)

```bash
# You need to include your CSC project ID in the description with "csc_project:" prefix
# Replace "2015319" with your actual CSC project NUMBER (without "project_" prefix)
oc new-project my-demo-project --description="csc_project: 2015319"

# You can also add a human-readable description:
# oc new-project my-demo-project --description="My demo application for CSC Rahti. csc_project: 2015319"

# To find your CSC project ID:
# 1. Go to https://my.csc.fi/
# 2. Login with your CSC credentials  
# 3. Your project ID is shown as "project_XXXXXXX" - use only the number part
```

**Important**: You must use the format `csc_project: XXXXXXX` (with only the number, no "project_" prefix) in the description, or the project creation will fail.

#### 4. Deploy the application

**Windows (PowerShell):**
```powershell
# Simple deployment using batch script
.\deploy.bat deploy

# Or manual deployment:
oc new-build --name=csc-rahti-demo --binary --strategy=docker
oc start-build csc-rahti-demo --from-dir=. --follow
oc apply -f k8s/
```

**Linux/macOS:**
```bash
# Simple deployment using shell script
./deploy.sh deploy

# Or manual deployment:
oc new-build --name=csc-rahti-demo --binary --strategy=docker
oc start-build csc-rahti-demo --from-dir=. --follow
oc apply -f k8s/
```

#### 5. Check deployment status

**Windows:**
```powershell
.\deploy.bat status
```

**Linux/macOS:**
```bash
./deploy.sh status
```

**Manual status check (all platforms):**
```bash
# Check pods
oc get pods -l app=csc-rahti-demo

# Check services and routes
oc get svc,route -l app=csc-rahti-demo

# Get application URL
oc get route csc-rahti-demo-route -o jsonpath='{.spec.host}'
```

#### 6. View application logs

**Windows:**
```powershell
.\deploy.bat logs
```

**Linux/macOS:**
```bash
./deploy.sh logs
```

**Manual log viewing (all platforms):**
```bash
# View logs from all pods
oc logs -l app=csc-rahti-demo -f

# View logs from specific pod
oc logs deployment/csc-rahti-demo -f
```

### 3. Deploy the application

Simple way:
```bash
chmod +x deploy.sh
./deploy.sh deploy
```

Manual way:
```bash
# Build image
oc new-build --name=csc-rahti-demo --binary --strategy=docker
oc start-build csc-rahti-demo --from-dir=. --follow

# Deploy application
oc apply -f k8s/
```

### 4. Check status

```bash
./deploy.sh status
```

### 5. View logs

```bash
./deploy.sh logs
```

## 🔧 Development

### Repository Management Best Practices

#### Branch Strategy for Students
```bash
# Create feature branches for major changes
git checkout -b feature/add-database
# Make your changes
git add .
git commit -m "Add PostgreSQL database integration"
git push origin feature/add-database

# Create pull request on GitHub, then merge to main
# After merging, clean up:
git checkout main
git pull origin main
git branch -d feature/add-database
```

#### Collaboration with Team Members
```bash
# Add team member's fork as remote
git remote add teammate https://github.com/TEAMMATE-USERNAME/csc-rahti-demo.git

# Fetch their changes
git fetch teammate

# Create branch to review their work
git checkout -b review-teammate-feature teammate/main

# Merge specific changes
git checkout main
git merge teammate/feature-branch
```

#### Keeping Dependencies Updated
```bash
# Check for updates
pip list --outdated

# Update requirements.txt
pip freeze > requirements.txt

# Test with new versions
python app.py

# Commit dependency updates
git add requirements.txt
git commit -m "Update Python dependencies"
git push origin main
```

### Local Development Setup

#### Windows
```powershell
# Create virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Start application
python app.py

# Alternative: Use Python module syntax
python -m flask run --host=0.0.0.0 --port=8080
```

#### Linux/macOS
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start application
python app.py

# Alternative: Use Flask CLI
export FLASK_APP=app.py
export FLASK_ENV=development
flask run --host=0.0.0.0 --port=8080
```

**Application will be available at:** http://localhost:8080

### Container Development

#### Building and testing locally

**Windows (PowerShell):**
```powershell
# Build Docker image
docker build -t csc-rahti-demo .

# Run container
docker run -p 8080:8080 csc-rahti-demo

# Run with environment variables
docker run -p 8080:8080 -e FLASK_ENV=development csc-rahti-demo

# Run with volume mount for development
docker run -p 8080:8080 -v ${PWD}:/app csc-rahti-demo
```

**Linux/macOS:**
```bash
# Build Docker image
docker build -t csc-rahti-demo .

# Run container
docker run -p 8080:8080 csc-rahti-demo

# Run with environment variables
docker run -p 8080:8080 -e FLASK_ENV=development csc-rahti-demo

# Run with volume mount for development
docker run -p 8080:8080 -v $(pwd):/app csc-rahti-demo
```

### Local development

```bash
# Install dependencies
pip install -r requirements.txt

# Start application
python app.py
```

Application starts at: http://localhost:8080

### Docker development

```bash
# Build image
docker build -t csc-rahti-demo .

# Run container
docker run -p 8080:8080 csc-rahti-demo
```

## 📊 API Endpoints

The application provides several REST API endpoints for different purposes:

- **`GET /`** - Home page with interactive web interface
  - Displays system information and application features
  - Includes API testing interface
  - Responsive design for mobile and desktop
  
- **`GET /health`** - Kubernetes liveness probe endpoint
  - Returns HTTP 200 if application is healthy
  - Used by Kubernetes to restart unhealthy pods
  - Simple JSON response: `{"status": "healthy"}`
  
- **`GET /ready`** - Kubernetes readiness probe endpoint  
  - Returns HTTP 200 when application is ready to serve traffic
  - Used by Kubernetes to control load balancer traffic
  - Checks database connections and external dependencies
  
- **`GET /info`** - System information endpoint (JSON)
  - Returns detailed system information
  - Includes hostname, platform, Python version
  - Memory usage and environment details
  
- **`GET /api/data`** - Demo API endpoint with sample data
  - Returns structured JSON with sample items
  - Includes timestamps and server information
  - Used for testing API connectivity

## 🔒 Security

The application follows CSC Rahti security requirements:

- **Non-root user** - Application runs as non-root user
- **Security Context** - Proper security settings
- **Read-only root filesystem** - Support for read-only root filesystem
- **Resource limits** - CPU and memory limits
- **Network policies** - Network traffic restrictions

## 📈 Monitoring and Scaling

### Horizontal Pod Autoscaler (HPA)

The application supports automatic scaling:
- **Min replicas**: 1
- **Max replicas**: 5
- **CPU threshold**: 70%
- **Memory threshold**: 80%

### Health Checks

- **Liveness probe**: `/health` endpoint
- **Readiness probe**: `/ready` endpoint

## 🗄️ Storage

The application supports persistent storage:
- **PVC**: 1Gi standard storage
- **Access mode**: ReadWriteOnce

## 🌐 Networking

### Routes and Services

- **HTTPS**: Automatic TLS termination
- **Load balancing**: HAProxy-based
- **Timeout**: 60 seconds

### Network Policies

- Allows incoming traffic on port 8080
- Allows all outgoing traffic

## 🛠️ Troubleshooting

### Git and GitHub Issues

**1. "Permission denied" when pushing**
```bash
# Make sure you're pushing to your fork, not the original
git remote -v
# Should show your username, not Vikke82

# If wrong, update remote:
git remote set-url origin https://github.com/YOUR-USERNAME/csc-rahti-demo.git
```

**2. "Repository not found"**
```bash
# Check if you forked the repository
# Go to: https://github.com/YOUR-USERNAME/csc-rahti-demo
# If it doesn't exist, fork it first

# Make sure remote URL is correct
git remote get-url origin
```

**3. Merge conflicts when updating from upstream**
```bash
# Fix conflicts manually, then:
git add .
git commit -m "Resolve merge conflicts"
git push origin main
```

**4. Want to start over completely**
```bash
# Delete local repository and re-clone
cd ..
rm -rf csc-rahti-demo  # Linux/macOS
# rmdir /s csc-rahti-demo  # Windows

# Re-clone your fork
git clone https://github.com/YOUR-USERNAME/csc-rahti-demo.git
```

### OpenShift/Rahti Issues

### Common issues

1. **Image pull errors** (e.g., "Back-off pulling image")
   ```bash
   # Check if the image exists
   oc get imagestreams
   oc describe imagestream csc-rahti-demo
   
   # If image doesn't exist, build it first:
   oc new-build --name=csc-rahti-demo --binary --strategy=docker
   oc start-build csc-rahti-demo --from-dir=. --follow
   
   # Then update the deployment to use the correct image:
   oc set image deployment/csc-rahti-demo csc-rahti-demo=image-registry.openshift-image-registry.svc:5000/my-demo-project/csc-rahti-demo:latest
   ```

2. **Project creation fails**
   ```bash
   # Make sure you use the correct format:
   oc new-project my-project --description="csc_project: YOUR_NUMBER"
   # NOT: --description="project_YOUR_NUMBER"
   ```

3. **Deployment won't start**
   ```bash
   oc logs deployment/csc-rahti-demo
   oc describe deployment csc-rahti-demo
   ```

4. **Route not working**
   ```bash
   oc get routes
   oc describe route csc-rahti-demo-route
   ```

### Debug commands

```bash
# Pod status
oc get pods -l app=csc-rahti-demo

# Events
oc get events --sort-by=.metadata.creationTimestamp

# Describe deployment
oc describe deployment csc-rahti-demo

# Port forward (debugging)
oc port-forward svc/csc-rahti-demo-service 8080:8080
```

## 🧹 Cleanup

### Remove all application resources

**Windows:**
```powershell
.\deploy.bat cleanup
```

**Linux/macOS:**
```bash
./deploy.sh cleanup
```

### Manual cleanup (all platforms)
```bash
# Remove application resources
oc delete all,configmap,secret,pvc,networkpolicy,hpa -l app=csc-rahti-demo

# Remove build resources
oc delete imagestream,buildconfig csc-rahti-demo

# Remove entire project (careful!)
oc delete project PROJECT_NAME
```

### Verify cleanup
```bash
# Check remaining resources
oc get all -l app=csc-rahti-demo

# Should return "No resources found"
```

## 📚 Useful links

- [CSC Rahti documentation](https://docs.csc.fi/cloud/rahti/)
- [OpenShift documentation](https://docs.openshift.com/)
- [Kubernetes documentation](https://kubernetes.io/docs/)
- [Flask documentation](https://flask.palletsprojects.com/)

## 🤝 Support

If you encounter issues:
1. Check [CSC documentation](https://docs.csc.fi/cloud/rahti/)
2. Contact [CSC support](https://research.csc.fi/support)

## 📄 License

This demo application is intended for educational and demonstration purposes.

---

**Note**: Remember to change default passwords and API keys in production use!
#   r a h t i - d e m o - N a f i s e h  
 