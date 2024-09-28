# Author: Adis Kljajic
# Date Written: 09/27/2024
# React-Native Automation Advanced With Navigations

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
mkdir -p src/assets/{fonts,media,images,theme} src/config src/components/{common,main} src/navigations src/styles src/screens src/constants{actionTypes,routeNames} src/helpers src/utils src/context/{actions,initialStates,reducers}

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
app_file_initial_contents=$(cat <<EOL
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

# Write the content directly to App.js
echo "$app_file_initial_contents" > App.js

# Write Initial Navigation Index.js Setup
app_navigations_initial_contents=$(cat <<EOL
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { Text } from 'react-native';

const AppNavContainer = () => {
    return (
        <NavigationContainer>
            <Text>Hello World</Text>
        </NavigationContainer>
    )
}
export default AppNavContainer;
EOL
)
# Write the content directly to App.js
echo "$app_navigations_initial_contents" > src/navigations/index.js

# Update App.js with the new Navigation Setup
app_navigation_update_contents=$(cat <<EOL
import React from 'react';
import AppNavContainer from './src/navigations';

const App = () => {
    return (
        <AppNavContainer></AppNavContainer>
    );
};

export default App;
EOL
)
# Write the content directly to App.js
echo "$app_navigation_update_contents" > App.js

# Create the Home Navigations
# Write the content directly to App.js
echo "$home_navigator_initial_contents" > src/navigations/HomeNavigator.js

# Install the React Native Stack Navigation
yarn add @react-navigation/stack

# Install the React Native Drawer Navigation
yarn add @react-navigation/drawer


# Create the Home Navigator File Contents
home_navigator_initial_file_contents=$(cat <<EOL
import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import { View, Text } from 'react-native'

const Settings = () => {
    return(
    <View>
        <Text>Hello From Settings</Text>
    </View>
    )
}

const Dashboard = () => {
    return(
    <View>
        <Text>Hello From Dashboard</Text>
    </View>
)
}

const HomeNavigator = () => {
    const HomeStack = createStackNavigator();
    return (
        <HomeStack.Navigator initialRouteName={Dashboard}>
          <HomeStack.Screen name="DASHBOARD" component={Dashboard}></HomeStack.Screen>
          <HomeStack.Screen name="SETTINGS" component={Settings}></HomeStack.Screen>
        </HomeStack.Navigator>
    )
}
export default HomeNavigator
EOL
)

# Write the content directly to HomeNavigator.js
echo "$home_navigator_initial_file_contents" > src/navigations/HomeNavigator.js


# Create the Auth Navigator File Contents
auth_navigator_initial_file_contents=$(cat <<EOL
import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import { View, Text } from 'react-native'

const Welcome = () => {
    return(
    <View>
        <Text>Hello From Welcome</Text>
    </View>
)
}

const Login = () => {
    return(
    <View>
        <Text>Hello From Login</Text>
    </View>
)
}

const AuthNavigator = () => {
    const AuthStack = createStackNavigator();
    return (
        <AuthStack.Navigator screenOptions={{headerShown: true}}>
            <AuthStack.Screen name="WELCOME" component={Welcome}></AuthStack.Screen>
            <AuthStack.Screen name="LOGIN" component={Login}></AuthStack.Screen>
        </AuthStack.Navigator>
    );
};
export default AuthNavigator
EOL
)

# Write the content directly to AuthNavigator.js
echo "$auth_navigator_initial_file_contents" > src/navigations/AuthNavigator.js


# Create the Drawer Navigator File Contents
drawer_navigator_initial_file_contents=$(cat <<EOL
import React from 'react'
import { createDrawerNavigator } from '@react-navigation/drawer'
import HomeNavigator from './HomeNavigator'

const DrawerNavigator = () => {
    const DrawerStack = createDrawerNavigator();
    return (
        <Drawer.Navigator>
            <Drawer.Screen name="Home" component={HomeNavigator} />
        </Drawer.Navigator>
    );
};
export default DrawerNavigator
EOL
)

# Write the content directly to AuthNavigator.js
echo "$drawer_navigator_initial_file_contents" > src/navigations/DrawerNavigator.js

# Update The Initial Navigation Index.JS File
loggedin_update_file_contents=$(cat <<EOL
import React from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { Text } from 'react-native'
import AuthNavigator from './AuthNavigator'
import DrawerNavigator from './DrawerNavigator'

const AppNavContainer = () => {
    const isLoggedIn = false;
    return (
        <NavigationContainer>
            {isLoggedIn ? <DrawerNavigator/>:<AuthNavigator/>}
        </NavigationContainer>
    )
}
export default AppNavContainer
EOL
)

# Write the content directly to AuthNavigator.js
echo "$loggedin_update_file_contents" > src/navigations/index.js

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
npx react-native start --reset-cache &

# Give the packager a moment to start
sleep 5  # Adjust the wait time if necessary

# Run on iOS
npx react-native run-ios &

# Run on Android
npx react-native run-android &

# Wait for both processes to finish
wait

# Instructions for further actions
echo "Both iOS and Android apps should now be running."

echo "Project setup for '$appName' complete! App.js has been created."
