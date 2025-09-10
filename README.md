# CSC Rahti Demo Application

This is a demonstration application for CSC's Rahti container platform. The application is a Python Flask-based web application optimized to run in OpenShift/OKD environments.

## 🚀 Features

- **Flask web application** - Simple and fast Python framework
- **Rahti compatible** - Optimized for CSC's Rahti platform
- **Security** - Non-root user, secure settings
- **Health checks** - Kubernetes-compatible health checks
- **Automatic scaling** - HPA (Horizontal Pod Autoscaler) support
- **Persistent storage** - Support for persistent storage
- **Logging** - Built-in logging and monitoring

## 📋 Requirements

- [OpenShift CLI (oc)](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
- CSC account and access to Rahti platform
- Docker (for development)

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

## 🚀 Deployment to Rahti

### 1. Login to CSC Rahti

```bash
# Method 1: Direct API login
oc login https://api.2.rahti.csc.fi:6443

# Method 2: Get login command from web console
# 1. Go to https://rahti.csc.fi/
# 2. Login with your CSC credentials
# 3. Click your username in top-right corner
# 4. Select "Copy login command"
# 5. Paste the command in your terminal
```

### 2. Create a new project (if needed)

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

- `GET /` - Home page
- `GET /health` - Health check
- `GET /ready` - Readiness check
- `GET /info` - System information (JSON)
- `GET /api/data` - Demo API data

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

Remove all resources:
```bash
./deploy.sh cleanup
```

Or manually:
```bash
oc delete all,configmap,secret,pvc,networkpolicy,hpa -l app=csc-rahti-demo
oc delete imagestream,buildconfig csc-rahti-demo
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
