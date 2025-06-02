#!/bin/bash

DEFAULT_FOLDER="/var/www/"
FOLDER=${1:-$DEFAULT_FOLDER}

# Set ownership to your user and www-data group
sudo chown -R $USER:www-data "$FOLDER"

# Set permissions for existing files, user and group, but no others.
sudo chmod -R 770 "$FOLDER"

# Set setgid bit to inherit group ownership for new files
sudo chmod -R g+s "$FOLDER"

# Set default permissions for new directories
sudo setfacl -d -R -m u:$USER:rwx "$FOLDER"
sudo setfacl -d -R -m g:www-data:rwx "$FOLDER"
sudo setfacl -d -R -m o:--- "$FOLDER"

echo "Base permissions set for $FOLDER"
echo ""

# Function to check if www-data has execute permission on a directory
check_execute_permission() {
    local dir="$1"
    # Get the permissions for www-data group
    local perms=$(getfacl "$dir" 2>/dev/null | grep "group:www-data:" | head -1)

    # If no ACL entry for www-data, check traditional permissions
    if [[ -z "$perms" ]]; then
        # Check if directory is group-readable and group is www-data
        local group=$(stat -c "%G" "$dir")
        local mode=$(stat -c "%a" "$dir")
        local group_perms=${mode:1:1}

        if [[ "$group" == "www-data" ]] && [[ $group_perms -ge 5 ]]; then
            return 0  # Has execute permission
        else
            return 1  # Missing execute permission
        fi
    else
        # Check ACL permissions for execute bit
        if [[ "$perms" == *"x"* ]]; then
            return 0  # Has execute permission
        else
            return 1  # Missing execute permission
        fi
    fi
}

# Check parent directories for proper permissions
echo "Checking parent directory permissions..."
current_path=$(realpath "$FOLDER")
parents_need_fix=()

# Traverse up the directory tree
while [[ "$current_path" != "/" ]]; do
    current_path=$(dirname "$current_path")

    # Skip root directory
    if [[ "$current_path" == "/" ]]; then
        break
    fi

    echo -n "Checking $current_path... "

    if ! check_execute_permission "$current_path"; then
        echo "NEEDS FIX (www-data lacks execute permission)"
        parents_need_fix+=("$current_path")
    else
        echo "OK"
    fi
done

# Report results and ask user
if [[ ${#parents_need_fix[@]} -eq 0 ]]; then
    echo ""
    echo "✓ All parent directories have proper permissions for Apache access."
else
    echo ""
    echo "⚠ The following parent directories need execute permissions for www-data:"
    for dir in "${parents_need_fix[@]}"; do
        echo "  - $dir"
    done
    echo ""
    echo "Apache needs execute (x) permission on all parent directories to traverse"
    echo "the path and access your web files."
    echo ""
    read -p "Do you want to apply execute permissions for www-data to these parent directories? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Applying permissions to parent directories..."

        for dir in "${parents_need_fix[@]}"; do
            echo "Setting permissions on $dir"
            # Add execute permission for www-data group via ACL
            sudo setfacl -m g:www-data:x "$dir"
        done

        echo ""
        echo "✓ Parent directory permissions updated successfully!"
        echo "Apache should now be able to access files in $FOLDER"
    else
        echo ""
        echo "Parent directory permissions were not modified."
        echo "Note: Apache may not be able to access files in $FOLDER without these permissions."
    fi
fi

echo ""
echo "Script completed."
ls -al "$FOLDER"