#!/bin/bash
# Autograder setup script for Assignment 3 Module 1
# Sets up test environment and dependencies

set -e

echo "Setting up autograder environment..."

# Install required dependencies
apt-get update
apt-get install -y git python3 python3-pip

# No additional setup needed for this assignment
# Tests are purely static code checks

echo "Autograder environment setup complete."
