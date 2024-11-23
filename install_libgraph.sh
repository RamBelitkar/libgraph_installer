#!/bin/bash

# Update package lists
sudo apt-get update

# Upgrade packages
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y build-essential libsdl-image1.2 libsdl-image1.2-dev guile-2.2 guile-2.2-dev

# Download libgraph
wget http://download.savannah.gnu.org/releases/libgraph/libgraph-1.0.2.tar.gz

# Extract the tar.gz file
tar -xzvf libgraph-1.0.2.tar.gz

# Change to the libgraph directory
cd libgraph-1.0.2

# Patch the source code to fix compilation errors
# Add the declarations for missing functions at the beginning of text.c
sed -i '1s/^/#include <stdio.h>\\nvoid refresh_interrupt(int);\\nvoid delay(int);\\n/' text.c

# Fix type casting issues in text.c
sed -i 's/vsscanf(&template,/vsscanf((const char *)&template,/' text.c
sed -i 's/vsscanf(&input,/vsscanf((const char *)&input,/' text.c

# Configure and install libgraph
CPPFLAGS="$CPPFLAGS $(pkg-config --cflags-only-I guile-2.2) -fcommon" \
CFLAGS="$CFLAGS $(pkg-config --cflags-only-other guile-2.2) -fcommon" \
LDFLAGS="$LDFLAGS $(pkg-config --libs guile-2.2)" \
./configure

make && sudo make install

# Copy the libgraph libraries to /usr/lib
sudo cp /usr/local/lib/libgraph.* /usr/lib
