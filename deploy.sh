#!/bin/bash

# If not defined, use default python version
[[ -z $PYTHON_VERSION ]] && PYTHON_VERSION="3.11"

# Get the directory where the script is running
DEPLOYMENT_SOURCE="${DEPLOYMENT_SOURCE:-$(cd "$(dirname "$0")" && pwd)}"
DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-$DEPLOYMENT_SOURCE}"

echo "Starting custom deployment script"
echo "Deployment source: $DEPLOYMENT_SOURCE"
echo "Deployment target: $DEPLOYMENT_TARGET"

# Navigate to project folder
cd "$DEPLOYMENT_SOURCE" || exit 1

# Create and activate virtual environment
echo "Creating virtual environment"
python -m venv antenv
source antenv/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install production dependencies
if [ -f requirements.txt ]; then
    echo "Installing dependencies from requirements.txt"
    pip install -r requirements.txt
else
    echo "No requirements.txt found. Installing basic FastAPI dependencies"
    pip install fastapi uvicorn gunicorn
fi

# Create the startup script
echo "Creating startup script"
cat > startup.sh << EOF
#!/bin/bash

# Activate virtual environment
source antenv/bin/activate

# Get the number of workers based on CPU cores
WORKERS=\$((\$(nproc) * 2 + 1))

# Start Gunicorn with FastAPI application
cd "$DEPLOYMENT_TARGET"
gunicorn main:app --workers \$WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --timeout 600 --access-logfile '-' --error-logfile '-'
EOF

# Make startup script executable
chmod +x startup.sh

# Create web.config for Azure App Service
echo "Creating web.config"
cat > web.config << EOF
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="httpPlatformHandler" path="" verb="" modules="httpPlatformHandler" resourceType="Unspecified" />
    </handlers>
    <httpPlatform processPath="%HOME%\site\wwwroot\startup.sh"
                  arguments=""
                  stdoutLogEnabled="true"
                  stdoutLogFile="%HOME%\LogFiles\stdout.log"
                  startupTimeLimit="60">
      <environmentVariables>
        <environmentVariable name="PORT" value="%HTTP_PLATFORM_PORT%" />
      </environmentVariables>
    </httpPlatform>
  </system.webServer>
</configuration>
EOF

# Copy all files to deployment target if different from source
if [ "$DEPLOYMENT_SOURCE" != "$DEPLOYMENT_TARGET" ]; then
    echo "Copying files to deployment target"
    cp -r * "$DEPLOYMENT_TARGET"
fi

echo "Deployment completed successfully"
