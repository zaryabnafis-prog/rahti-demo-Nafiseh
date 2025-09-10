#!/bin/bash

# CSC Rahti Deployment Script
# This script helps deploy the application to CSC Rahti platform

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="csc-rahti-demo"
REGISTRY_URL="image-registry.openshift-image-registry.svc:5000"
NAMESPACE="${NAMESPACE:-$(oc project -q 2>/dev/null || echo 'default')}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if oc command is available
    if ! command -v oc &> /dev/null; then
        log_error "OpenShift CLI (oc) is not installed or not in PATH"
        log_info "Please install OpenShift CLI from: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html"
        exit 1
    fi
    
    # Check if logged in to OpenShift
    if ! oc whoami &> /dev/null; then
        log_error "Not logged in to OpenShift cluster"
        log_info "Please login using: oc login <cluster-url>"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

build_image() {
    log_info "Building Docker image..."
    
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile not found in current directory"
        exit 1
    fi
    
    # Create BuildConfig and ImageStream if they don't exist
    if ! oc get imagestream $PROJECT_NAME &> /dev/null; then
        log_info "Creating ImageStream..."
        oc create imagestream $PROJECT_NAME
    fi
    
    if ! oc get buildconfig $PROJECT_NAME &> /dev/null; then
        log_info "Creating BuildConfig..."
        oc new-build --name=$PROJECT_NAME --binary --strategy=docker
    fi
    
    # Start build
    log_info "Starting binary build..."
    oc start-build $PROJECT_NAME --from-dir=. --follow
    
    log_success "Image built successfully"
}

deploy_application() {
    log_info "Deploying application to Rahti..."
    
    # Apply Kubernetes manifests
    log_info "Applying ConfigMap and Secrets..."
    oc apply -f k8s/configmap.yaml
    
    log_info "Applying Deployment..."
    # Update deployment to use the built image
    sed "s|your-registry/csc-rahti-demo:latest|${REGISTRY_URL}/${NAMESPACE}/${PROJECT_NAME}:latest|g" k8s/deployment.yaml | oc apply -f -
    
    log_info "Applying Service and Route..."
    oc apply -f k8s/service.yaml
    
    log_info "Applying HPA (if supported)..."
    oc apply -f k8s/hpa.yaml || log_warning "HPA might not be supported in this cluster"
    
    log_info "Applying Storage and Network policies..."
    oc apply -f k8s/storage-and-network.yaml || log_warning "Some resources might not be supported"
    
    log_success "Application deployed successfully"
}

wait_for_deployment() {
    log_info "Waiting for deployment to be ready..."
    
    # Wait for deployment to be ready
    oc rollout status deployment/$PROJECT_NAME --timeout=300s
    
    log_success "Deployment is ready"
}

show_access_info() {
    log_info "Getting access information..."
    
    # Get route URL
    ROUTE_URL=$(oc get route $PROJECT_NAME-route -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
    
    if [ -n "$ROUTE_URL" ]; then
        log_success "Application is accessible at: https://$ROUTE_URL"
        log_info "Health check: https://$ROUTE_URL/health"
        log_info "API endpoint: https://$ROUTE_URL/api/data"
    else
        log_warning "Could not determine route URL. Check manually with: oc get routes"
    fi
    
    # Show pod status
    log_info "Pod status:"
    oc get pods -l app=$PROJECT_NAME
}

cleanup() {
    log_warning "Cleaning up resources..."
    
    read -p "Are you sure you want to delete all resources? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        oc delete all,configmap,secret,pvc,networkpolicy,hpa -l app=$PROJECT_NAME
        oc delete imagestream,buildconfig $PROJECT_NAME 2>/dev/null || true
        log_success "Resources cleaned up"
    else
        log_info "Cleanup cancelled"
    fi
}

show_help() {
    echo "CSC Rahti Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Build and deploy the application (default)"
    echo "  build     Build the Docker image only"
    echo "  status    Show deployment status"
    echo "  logs      Show application logs"
    echo "  cleanup   Remove all deployed resources"
    echo "  help      Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  NAMESPACE  OpenShift namespace to deploy to (default: current project)"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 build"
    echo "  NAMESPACE=my-project $0 deploy"
}

show_logs() {
    log_info "Showing application logs..."
    oc logs -l app=$PROJECT_NAME --tail=100 -f
}

show_status() {
    log_info "Deployment status:"
    echo ""
    
    echo "Pods:"
    oc get pods -l app=$PROJECT_NAME
    echo ""
    
    echo "Services:"
    oc get svc -l app=$PROJECT_NAME
    echo ""
    
    echo "Routes:"
    oc get routes -l app=$PROJECT_NAME
    echo ""
    
    echo "HPA:"
    oc get hpa -l app=$PROJECT_NAME 2>/dev/null || echo "No HPA found"
}

# Main script
main() {
    local command=${1:-deploy}
    
    case $command in
        deploy)
            check_prerequisites
            build_image
            deploy_application
            wait_for_deployment
            show_access_info
            ;;
        build)
            check_prerequisites
            build_image
            ;;
        status)
            check_prerequisites
            show_status
            ;;
        logs)
            check_prerequisites
            show_logs
            ;;
        cleanup)
            check_prerequisites
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
