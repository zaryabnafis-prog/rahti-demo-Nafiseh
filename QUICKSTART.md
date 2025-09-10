# 🚀 Quick Start Guide - CSC Rahti Demo

Tämä on nopea aloitusopas CSC Rahti Demo -sovelluksen käyttöönottoon.

## ⚡ Nopea käyttöönotto (5 minuuttia)

### 1. Esivalmistelut
```bash
# Lataa OpenShift CLI jos ei ole asennettu
# Windows: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-windows.zip
# Linux: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
# macOS: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-mac.tar.gz

# Kirjaudu CSC Rahtiin
oc login https://rahti.csc.fi/
```

### 2. Luo projekti
```bash
oc new-project my-demo-app
```

### 3. Deploy sovellus (Vaihtoehto A - Automaattinen)
```bash
# Linux/macOS
chmod +x deploy.sh
./deploy.sh deploy

# Windows
deploy.bat deploy
```

### 3. Deploy sovellus (Vaihtoehto B - Manuaalinen)
```bash
# 1. Luo image stream ja build config
oc new-build --name=csc-rahti-demo --binary --strategy=docker

# 2. Rakenna image
oc start-build csc-rahti-demo --from-dir=. --follow

# 3. Päivitä deployment.yaml -tiedostossa image-polku:
# image: image-registry.openshift-image-registry.svc:5000/NAMESPACE/csc-rahti-demo:latest

# 4. Deploy resurssit
oc apply -f k8s/
```

### 4. Tarkista tulos
```bash
# Katso podien status
oc get pods

# Hae sovelluksen URL
oc get routes

# Testaa sovellus
curl https://YOUR-ROUTE-URL/health
```

## 🎯 Mitä sovellus sisältää?

✅ **Flask Web App** - Python-pohjainen web-sovellus  
✅ **Health Checks** - `/health` ja `/ready` endpointit  
✅ **API Demo** - `/api/data` REST endpoint  
✅ **Responsive UI** - Moderni web-käyttöliittymä  
✅ **Auto-scaling** - HPA konfiguroitu  
✅ **Security** - Non-root user, security contexts  
✅ **Storage** - Persistent volume claim  
✅ **Monitoring** - Logging ja metrics  

## 🔧 Paikallinen kehitys

```bash
# 1. Asenna riippuvuudet
pip install -r requirements.txt

# 2. Käynnistä kehityspalvelin
python dev.py
# TAI
python app.py

# 3. Avaa selaimessa
http://localhost:8080
```

## 📊 Hyödyllisiä komentoja

```bash
# Status
oc get all -l app=csc-rahti-demo

# Lokit
oc logs -l app=csc-rahti-demo --tail=50 -f

# Port forward (testaus)
oc port-forward svc/csc-rahti-demo-service 8080:8080

# Scale manually
oc scale deployment/csc-rahti-demo --replicas=3

# Update image
oc start-build csc-rahti-demo --from-dir=.

# Delete everything
oc delete all,configmap,secret,pvc -l app=csc-rahti-demo
```

## 🐛 Troubleshooting

### Yleisimmät ongelmat:

**1. Pod ei käynnisty**
```bash
oc describe pod <pod-name>
oc logs <pod-name>
```

**2. Route ei toimi**
```bash
oc get routes
oc describe route csc-rahti-demo-route
```

**3. Image build epäonnistuu**
```bash
oc logs bc/csc-rahti-demo
```

**4. Permission denied**
- Varmista että käytät non-root useria
- Tarkista security context asetukset

## 📞 Tuki

- **CSC Rahti docs**: https://docs.csc.fi/cloud/rahti/
- **CSC Support**: https://research.csc.fi/support
- **OpenShift docs**: https://docs.openshift.com/

## 🎉 Valmis!

Sovelluksesi pitäisi nyt olla käynnissä Rahtissa. Onnittelut! 🎉

Seuraavat askeleet:
1. Muokkaa sovellusta omiin tarpeisiisi
2. Lisää tietokanta (PostgreSQL/MySQL)
3. Konfiguroi CI/CD pipeline
4. Lisää domain ja SSL-sertifikaatti
