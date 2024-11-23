#!/bin/bash

# Update package lists
sudo apt-get update

# Upgrade packages
sudo apt-get upgrade -y

# Install required packages if not already installed
for pkg in build-essential libsdl-image1.2 libsdl-image1.2-dev guile-2.2 guile-2.2-dev; do
    if ! dpkg -l | grep -q "$pkg"; then
        sudo apt-get install -y $pkg
    fi
done

# Download libgraph
wget http://download.savannah.gnu.org/releases/libgraph/libgraph-1.0.2.tar.gz || { echo "Failed to download libgraph"; exit 1; }

# Extract the tar.gz file
tar -xzvf libgraph-1.0.2.tar.gz || { echo "Failed to extract libgraph"; exit 1; }

# Change to the libgraph directory
cd libgraph-1.0.2 || { echo "Failed to access libgraph directory"; exit 1; }

# Patch the source code to fix compilation errors
sed -i '1i #include <stdio.h>\nvoid refresh_interrupt(int);\nvoid delay(int);\n' text.c
sed -i 's/vsscanf(&template,/vsscanf((const char *)&template,/' text.c
sed -i 's/vsscanf(&input,/vsscanf((const char *)&input,/' text.c

# Configure and install libgraph
CPPFLAGS="$CPPFLAGS $(pkg-config --cflags-only-I guile-2.2) -fcommon" \
CFLAGS="$CFLAGS $(pkg-config --cflags-only-other guile-2.2) -fcommon" \
LDFLAGS="$LDFLAGS $(pkg-config --libs guile-2.2)" \
./configure || { echo "Configuration failed"; exit 1; }

# Run make and make install separately
make || { echo "Make failed"; exit 1; }
sudo make install || { echo "Make install failed"; exit 1; }

# Verify if libraries exist before copying
if ls /usr/local/lib/libgraph.* 1> /dev/null 2>&1; then
    sudo cp /usr/local/lib/libgraph.* /usr/lib
    echo "Libraries copied successfully."
else
    echo "Libraries not found in /usr/local/lib. Make sure 'make install' was successful."
fi

# Validate installation
if ldconfig -p | grep -q "libgraph"; then
    echo "libgraph installed successfully."
else
    echo "libgraph installation failed."
fi

# Clean up
cd ..
rm -rf libgraph-1.0.2.tar.gz libgraph-1.0.2

echo "Script execution completed."
