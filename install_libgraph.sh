#!/bin/bash

# Ensure the script is run with superuser privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit 1
fi

# Update package lists and upgrade existing packages
echo "Updating package lists..."
sudo apt-get update && sudo apt-get upgrade -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt-get install -y build-essential libsdl-image1.2 libsdl-image1.2-dev guile-2.2 guile-2.2-dev wget git

# Download libgraph source
echo "Downloading libgraph source..."
wget http://download.savannah.gnu.org/releases/libgraph/libgraph-1.0.2.tar.gz

# Extract the source code
echo "Extracting libgraph source..."
tar -xzvf libgraph-1.0.2.tar.gz
cd libgraph-1.0.2 || { echo "Extraction failed. Exiting."; exit 1; }

# Apply patches to fix compilation errors
echo "Patching source files..."
# Add missing function declarations
sed -i '1i #include <stdio.h>\nvoid refresh_interrupt(int);\nvoid delay(int);\n' text.c

# Correct argument types and fix grscanf function in text.c
sed -i '/vsscanf(/c\        num = vsscanf(text, template, ap);' text.c
sed -i '/num = vsscanf(/i\        int num = 0; // Initialize num' text.c
sed -i '/num = vsscanf(/a\        }' text.c
sed -i '/vsscanf(text, template, ap);/i\        if (template && text) {' text.c

# Configure the build
echo "Configuring build..."
CPPFLAGS="$CPPFLAGS $(pkg-config --cflags-only-I guile-2.2) -fcommon" \
CFLAGS="$CFLAGS $(pkg-config --cflags-only-other guile-2.2) -fcommon" \
LDFLAGS="$LDFLAGS $(pkg-config --libs guile-2.2)" \
./configure

# Compile the source
echo "Compiling source..."
make clean && make

# Install the library
echo "Installing libgraph..."
sudo make install

# Verify installation and copy libraries
if ls /usr/local/lib/libgraph.* 1> /dev/null 2>&1; then
  echo "Copying libraries to /usr/lib..."
  sudo cp /usr/local/lib/libgraph.* /usr/lib
else
  echo "Error: Libraries not found in /usr/local/lib. Make sure 'make install' was successful."
  exit 1
fi

# Go back to the parent directory
cd ..

# Clone conio.h repository
echo "Cloning conio.h repository..."
git clone https://github.com/zoelabbb/conio.h.git
cd conio.h

# Install conio.h
echo "Installing conio.h..."
sudo make install

# Cleanup
echo "Cleaning up..."
cd ..
rm -rf libgraph-1.0.2 libgraph-1.0.2.tar.gz conio.h

echo "Installation completed successfully!"
