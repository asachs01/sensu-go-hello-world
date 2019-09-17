#!/bin/sh

# This is a shell script that runs a basic "Hello World"
# However, we're using it as an asset in Sensu Go
# For info on how assets work, see https://docs.sensu.io/sensu-go/latest/reference/assets/

# First, let's get our "Hello World" string as a variable
STRING="Hello World"

# Then, let's echo it to stdout
echo $STRING

# Now, let's set a condition: If for some reason, the command fails, it should exit with a 2 (error)
if [ $? -eq 0 ]; then
    exit 0
else
    exit 2
fi