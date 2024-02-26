#!/bin/bash

DC_VERSION="9.0.7"
S3_BUCKET="wsr-test-code"
REPORTS_DIRECTORY="reports"

# Download and run OWASP Dependency-Check from GitHub releases
wget "https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip" -O dependency-check.zip

if [ $? -ne 0 ]; then
  echo "Error downloading Dependency-Check ZIP."
  exit 1
fi

unzip dependency-check.zip

if [ $? -ne 0 ]; then
  echo "Error unzipping Dependency-Check."
  exit 1
fi

# Find the Dependency-Check directory
DC_DIRECTORY=$(find . -maxdepth 1 -type d -name 'dependency-check*')

if [ -z "$DC_DIRECTORY" ]; then
  echo "Error finding Dependency-Check directory."
  exit 1
fi

cd "$DC_DIRECTORY"

# Run Dependency-Check scan and capture log
./bin/dependency-check.sh --scan . --out "$REPORTS_DIRECTORY" 2>&1 | tee dependency-check-scan.log

if [ $? -ne 0 ]; then
  echo "Error running Dependency-Check scan."
  cat dependency-check-scan.log  # Print detailed logs
  exit 1
fi

# Remove previous contents from S3 bucket
aws s3 rm --recursive "s3://${S3_BUCKET}/dependency-check/"

# Check if reports directory exists
if [ -d "$REPORTS_DIRECTORY" ]; then
  # Sync Dependency-Check reports to S3 bucket
  aws s3 sync "$REPORTS_DIRECTORY"/ "s3://${S3_BUCKET}/dependency-check/"
  if [ $? -ne 0 ]; then
    echo "Error syncing Dependency-Check reports to S3."
    exit 1
  fi

  # Upload HTML report to S3
  if [ -f "$REPORTS_DIRECTORY/dependency-check-report.html" ]; then
    aws s3 cp "$REPORTS_DIRECTORY/dependency-check-report.html" "s3://${S3_BUCKET}/dependency-check/"
    if [ $? -ne 0 ]; then
      echo "Error uploading HTML report to S3."
      exit 1
    fi
  else
    echo "HTML report not found. Skipping HTML upload."
  fi
else
  echo "The reports directory does not exist. Skipping S3 sync and HTML upload."
fi
