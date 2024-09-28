# How To Run File-- ./setup_project.sh ApplicationName
# If you get permission denied run the following command:
# chmod +x setup_project.sh

#!/bin/bash

# Function to check and install jq if not found
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        # Install jq using Homebrew
        if command -v brew &> /dev/null; then
            brew install jq
        else
            echo "Homebrew not found. Please install Homebrew to continue."
            exit 1
        fi
    fi
}

# Check if jq is installed
check_jq

# Check if an app name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <appName>"
    exit 1
fi

appName="$1"

# Initialize a new React Native project with
# the provided app name, skipping installation
npx @react-native-community/cli@latest init "$appName" --skip-install

# Change into the project directory
cd "$appName" || exit

# Install dependencies
npm install

# Install CocoaPods
cd ios
pod install
cd ..

# Create src folder and necessary directories
mkdir -p src/assets/{fonts,images,theme} src/config src/components src/navigation src/styles src/screens src/constants src/helpers src/utils src/context/{actions,initialStates,reducers}

# Install React Navigation and its dependencies
yarn add @react-navigation/native

# Install additional packages for React Navigation
yarn add react-native-reanimated react-native-gesture-handler react-native-screens react-native-safe-area-context @react-native-community/masked-view

# Run CocoaPods installation for iOS
npx pod-install ios

# Update package.json to include pod-install under scripts
jq '.scripts += {"pod": "npx pod-install ios"}' package.json > temp.json && mv temp.json package.json

# Remove App.tsx if it exists
if [ -f App.tsx ]; then
    rm App.tsx
fi

# This is App.js Content
# Create App.js content as a variable
file_content=$(cat <<EOL
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { Text } from 'react-native';

const App = () => {
    return (
        <NavigationContainer>
            <Text>Hello World</Text>
        </NavigationContainer>
    );
};

export default App;
EOL
)

echo "Project setup for '$file_content' complete!"

# Write the content directly to App.js
echo "$file_content" > App.js

echo "Project setup for '$appName' complete! App.js has been created."



echo "Project setup for '$appName' complete!"

# Dynamically kill any process running on port 8081
echo "Checking for any running processes on port 8081..."
pid=$(lsof -ti:8081)
if [ -n "$pid" ]; then
    echo "Killing process $pid using port 8081..."
    kill -9 $pid
else
    echo "No process found on port 8081."
fi

# Start Project
# Start React Native packager
echo "Starting React Native packager..."
npx react-native start --reset-cache

# Give the packager a moment to start
sleep 10  # Increase the wait time if necessary

# Open in IOS
i

# Open in Android
a 

echo "Project setup for '$appName' complete! App.js has been created."
