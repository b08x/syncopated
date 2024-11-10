#!/bin/bash

# Collection build and test script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${YELLOW}==> ${1}${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}==> ${1}${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}==> ERROR: ${1}${NC}"
}

# Function to build a collection
build_collection() {
    local collection_path="$1"
    local collection_name="$(basename "$collection_path")"
    
    print_status "Building collection: $collection_name"
    
    # Navigate to collection directory
    cd "$collection_path"
    
    # Ensure galaxy.yml exists
    if [ ! -f "galaxy.yml" ]; then
        print_error "galaxy.yml not found in $collection_name"
        return 1
    fi
    # Build the collection
    ansible-galaxy collection build --force
    
    # Return to original directory
    cd - > /dev/null
    
    print_success "Built collection: $collection_name"
}

# Function to test a collection
test_collection() {
    local collection_path="$1"
    local collection_name="$(basename "$collection_path")"
    
    print_status "Testing collection: $collection_name"
    
    # Check for test requirements
    if [ -f "$collection_path/requirements-test.txt" ]; then
        pip install -r "$collection_path/requirements-test.txt"
    fi
    
    # Run ansible-test sanity checks if tests directory exists
    if [ -d "$collection_path/tests" ]; then
        cd "$collection_path"
        ansible-test sanity --docker default
        cd - > /dev/null
    fi
    
    print_success "Tested collection: $collection_name"
}

# Main script
main() {
    local collections_dir="collections"
    
    # Ensure we're in the right directory
    if [ ! -d "$collections_dir" ]; then
        print_error "Collections directory not found. Run this script from the root of your ansible collections repository."
        exit 1
    fi
    
    # Create dist directory if it doesn't exist
    mkdir -p dist
    
    # Process each collection
    for collection in "$collections_dir"/*; do
        if [ -d "$collection" ]; then
            # Build the collection
            if ! build_collection "$collection"; then
                print_error "Failed to build collection: $(basename "$collection")"
                exit 1
            fi
            
            # Test the collection
            if ! test_collection "$collection"; then
                print_error "Failed to test collection: $(basename "$collection")"
                exit 1
            fi
            
            # Move built collection to dist directory
            mv "$collection"/*.tar.gz dist/
            
        fi
    done

    cd dist

    for collection in *.tar.gz; do
        ansible-galaxy collection install $collection --force
        sleep 1
    done
    
    print_success "All collections built and tested successfully!"
    print_status "Built collections can be found in the dist directory"
}

# Run main function
main "$@"