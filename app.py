#!/usr/bin/env python3
"""
CSC Rahti Demo Application
A simple Flask web application optimized for CSC Rahti container platform.
"""

import os
import sys
import logging
from datetime import datetime
from flask import Flask, render_template, jsonify, request
import socket
import platform

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

# Create Flask application
app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'csc-rahti-demo-key')
app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'

# Get environment information
def get_system_info():
    """Get system information for display"""
    return {
        'hostname': socket.gethostname(),
        'platform': platform.platform(),
        'python_version': platform.python_version(),
        'timestamp': datetime.now().isoformat(),
        'environment': {
            'user': os.environ.get('USER', 'unknown'),
            'home': os.environ.get('HOME', 'unknown'),
            'path': os.environ.get('PATH', 'unknown')[:100] + '...',
            'port': os.environ.get('PORT', '8080')
        }
    }

@app.route('/')
def home():
    """Home page route"""
    logger.info("Home page requested")
    system_info = get_system_info()
    return render_template('index.html', system_info=system_info)

@app.route('/health')
def health_check():
    """Health check endpoint for Kubernetes/OpenShift"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'hostname': socket.gethostname()
    })

@app.route('/ready')
def readiness_check():
    """Readiness check endpoint for Kubernetes/OpenShift"""
    return jsonify({
        'status': 'ready',
        'timestamp': datetime.now().isoformat(),
        'hostname': socket.gethostname()
    })

@app.route('/info')
def info():
    """System information endpoint"""
    return jsonify(get_system_info())
@app.route('/api/myname')
def my_name():
    """Return my name via API"""
    return jsonify({
        "name": "Nafiseh Babapourzaryab"
    })

@app.route('/api/data')
def api_data():
    """Sample API endpoint"""
    data = {
        'message': 'Nafiseh Babapourzaryab, welcome!!',
        'data': [
            {'id': 1, 'name': 'First Item', 'value': 42},
            {'id': 2, 'name': 'Second Item', 'value': 84},
            {'id': 3, 'name': 'Third Item', 'value': 126}
        ],
        'timestamp': datetime.now().isoformat(),
        'server': socket.gethostname()
    }
    return jsonify(data)

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return render_template('error.html', 
                         error_code=404, 
                         error_message="Page not found"), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    logger.error(f"Internal server error: {error}")
    return render_template('error.html', 
                         error_code=500, 
                         error_message="Internal server error"), 500

if __name__ == '__main__':
    # Get port from environment variable (Rahti sets this)
    port = int(os.environ.get('PORT', 8080))
    
    logger.info(f"Starting CSC Rahti Demo Application on port {port}")
    logger.info(f"System info: {get_system_info()}")
    
    # Run the application
    # Note: In production, this should be run with a proper WSGI server
    # but for demo purposes, Flask's built-in server is sufficient
    app.run(
        host='0.0.0.0',  # Important: bind to all interfaces for containers
        port=port,
        debug=app.config['DEBUG']
    )
