#!/bin/bash

# Autograder test runner for Assignment 3 Module 1
# This script is called by Gradescope's autograder environment

set -e

STUDENT_REPO="${AUTOGRADER_DIR}/source/student_repo"
RESULTS_DIR="${AUTOGRADER_DIR}/results"

# Create results directory if it doesn't exist
mkdir -p "${RESULTS_DIR}"

echo "Testing Assignment 3 Module 1 requirements..."

# Test 0.1: Signed Git Commit
echo "Checking for signed commits..."
cd "${STUDENT_REPO}"
if git log --show-signature -1 | grep -q "Good\|Verified"; then
    echo "✓ Found signed commit"
else
    echo "✗ No signed commit found"
fi

# Test 0.2: Docker image (manual check - already pushed to DockerHub)
echo "Docker image should be at: ep3523/assign3:assign3mod1handin"

# Test 1.2: SECRET_KEY environment variable
echo "Checking SECRET_KEY configuration..."
if grep -q "os.environ.get.*SECRET_KEY" "${STUDENT_REPO}/GiftcardSite/GiftcardSite/settings.py"; then
    echo "✓ SECRET_KEY uses environment variables"
else
    echo "✗ SECRET_KEY not configured for environment"
fi

# Test 2.1: Dangerous monitoring removed
echo "Checking for dangerous monitoring..."
if ! grep -r "password" "${STUDENT_REPO}/GiftcardSite" --include="*.py" | grep -i "log\|print"; then
    echo "✓ No password logging found"
else
    echo "✗ Found potential password logging"
fi

# Test 2.2: 404 metrics counter
echo "Checking for 404 metrics..."
if grep -q "http_404_total" "${STUDENT_REPO}/GiftcardSite/LegacySite/middleware.py"; then
    echo "✓ 404 metrics counter found"
else
    echo "✗ 404 metrics counter not found"
fi

echo "All tests completed!"
