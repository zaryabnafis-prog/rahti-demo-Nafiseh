#!/usr/bin/env python3
"""
Local development server
Run this script to start the application locally for development
"""

import os
import sys
from pathlib import Path

# Add current directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

# Load environment variables from .env file if it exists
env_file = current_dir / '.env'
if env_file.exists():
    from dotenv import load_dotenv
    load_dotenv(env_file)
    print(f"Loaded environment variables from {env_file}")

# Set development environment
os.environ.setdefault('FLASK_ENV', 'development')
os.environ.setdefault('FLASK_DEBUG', 'True')
os.environ.setdefault('PORT', '8080')

# Import and run the app
if __name__ == '__main__':
    try:
        from app import app
        
        port = int(os.environ.get('PORT', 8080))
        debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
        
        print(f"Starting development server on http://localhost:{port}")
        print(f"Debug mode: {debug}")
        print("Press Ctrl+C to stop the server")
        
        app.run(
            host='127.0.0.1',  # Only bind to localhost for development
            port=port,
            debug=debug
        )
    except ImportError as e:
        print(f"Error importing app: {e}")
        print("Make sure you have installed the requirements:")
        print("pip install -r requirements.txt")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nShutting down development server...")
        sys.exit(0)
