#!/bin/bash

# Source the environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please copy .env.example to .env and fill in your values."
    exit 1
fi
