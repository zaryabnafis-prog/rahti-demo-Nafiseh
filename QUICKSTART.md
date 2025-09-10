# 🚀 Quick Start Guide - CSC Rahti Demo

This is a quick start guide for deploying the CSC Rahti Demo application.

## ⚡ Quick Deployment (5 minutes)

### 1. Prerequisites
```bash
# Download OpenShift CLI if not installed
# Windows: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-windows.zip
# Linux: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
# macOS: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-mac.tar.gz

# Login to CSC Rahti
oc login https://rahti.csc.fi/
```

### 2. Create project
```bash
oc new-project my-demo-app
```

### 3. Deploy application (Option A - Automatic)
```bash
# Linux/macOS
chmod +x deploy.sh
./deploy.sh deploy

# Windows
deploy.bat deploy
```

### 3. Deploy application (Option B - Manual)
```bash
# 1. Create image stream and build config
oc new-build --name=csc-rahti-demo --binary --strategy=docker

# 2. Build image
oc start-build csc-rahti-demo --from-dir=. --follow

# 3. Update image path in deployment.yaml:
# image: image-registry.openshift-image-registry.svc:5000/NAMESPACE/csc-rahti-demo:latest

# 4. Deploy resources
oc apply -f k8s/
```

### 4. Check results
```bash
# Check pod status
oc get pods

# Get application URL
oc get routes

# Test application
curl https://YOUR-ROUTE-URL/health
```

## 🎯 What does the application include?

✅ **Flask Web App** - Python-based web application  
✅ **Health Checks** - `/health` and `/ready` endpoints  
✅ **API Demo** - `/api/data` REST endpoint  
✅ **Responsive UI** - Modern web interface  
✅ **Auto-scaling** - HPA configured  
✅ **Security** - Non-root user, security contexts  
✅ **Storage** - Persistent volume claim  
✅ **Monitoring** - Logging and metrics  

## 🔧 Local development

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Start development server
python dev.py
# OR
python app.py

# 3. Open in browser
http://localhost:8080
```

## 📊 Useful commands

```bash
# Status
oc get all -l app=csc-rahti-demo

# Logs
oc logs -l app=csc-rahti-demo --tail=50 -f

# Port forward (testing)
oc port-forward svc/csc-rahti-demo-service 8080:8080

# Scale manually
oc scale deployment/csc-rahti-demo --replicas=3

# Update image
oc start-build csc-rahti-demo --from-dir=.

# Delete everything
oc delete all,configmap,secret,pvc -l app=csc-rahti-demo
```

## 🐛 Troubleshooting

### Most common issues:

**1. Pod won't start**
```bash
oc describe pod <pod-name>
oc logs <pod-name>
```

**2. Route not working**
```bash
oc get routes
oc describe route csc-rahti-demo-route
```

**3. Image build fails**
```bash
oc logs bc/csc-rahti-demo
```

**4. Permission denied**
- Make sure you're using non-root user
- Check security context settings

## 📞 Support

- **CSC Rahti docs**: https://docs.csc.fi/cloud/rahti/
- **CSC Support**: https://research.csc.fi/support
- **OpenShift docs**: https://docs.openshift.com/

## 🎉 Ready!

Your application should now be running in Rahti. Congratulations! 🎉

Next steps:
1. Modify the application for your needs
2. Add a database (PostgreSQL/MySQL)
3. Configure CI/CD pipeline
4. Add custom domain and SSL certificate
