#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: source $0 [create|activate|deactivate|install] [venv_name]"
}

# Check if the script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced. Use 'source $0 [command] [venv_name]'"
    usage
    exit 1
fi

# Get the current path
current_path=$(pwd)

# Read name of venv via input option
venv_input="$2"

# Define the virtual environment directory based on input
set_venv_path() {
    if [ -z "$1" ]; then
        venv="$current_path/venv"
    else
        # Check if venv_input is an absolute path
        if [[ "$1" = /* ]]; then
            venv="$1"
        else
            venv="$current_path/$1"
        fi
    fi
}

# Function to create virtual environment
create_venv() {
    set_venv_path "$venv_input"
    if [ ! -d "$venv" ]; then
        python3 -m venv "$venv"
        echo "Virtual environment created at $venv"
    else
        echo "Virtual environment already exists at $venv"
    fi
}

# Function to activate virtual environment
activate_venv() {
    set_venv_path "$venv_input"
    if [ -d "$venv" ]; then
        if [ -f "$venv/bin/activate" ]; then
            eval "source $venv/bin/activate"
            echo "Activated virtual environment at $venv"
        else
            echo "Activation script not found at $venv/bin/activate"
        fi
    else
        echo "Virtual environment does not exist at $venv"
    fi
}

# Function to deactivate virtual environment
deactivate_venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
        echo "Deactivated virtual environment"
    else
        echo "No virtual environment is currently activated."
    fi
}

# Function to install requirements
install_requirements() {
    if [ -n "$VIRTUAL_ENV" ]; then
        requirements_path="$current_path/requirements.txt"
        if [ -f "$requirements_path" ]; then
            echo "Current virtual environment: $VIRTUAL_ENV"
            echo "Requirements file path: $requirements_path"
            read -r -p "Do you want to install the requirements from $requirements_path? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                pip install -r "$requirements_path"
            else
                echo "Installation cancelled."
            fi
        else
            echo "Error: requirements.txt file not found at $requirements_path"
        fi
    else
        echo "No virtual environment is currently activated."
    fi
}

# Handle the input command
case "$1" in
    create)
        venv_input="$2"
        create_venv
        ;;
    activate)
        venv_input="$2"
        activate_venv
        ;;
    deactivate)
        deactivate_venv
        ;;
    install)
        install_requirements
        ;;
    "")
        activate_venv
        ;;
    *)
        venv_input="$1"
        activate_venv
        ;;
esac

