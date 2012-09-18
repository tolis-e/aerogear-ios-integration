Integration Tests for the AeroGear-iOS library...
-------------------------------------------------

The project requires [CocoaPods](http://cocoapods.org/) for dependency management;

## SETUP

_BEFORE_ you can run the test, you need to run the following command inside of the AeroGear-iOS-Integration folder:

    pod install

This installs all the required dependencies and generates the _AeroGear-iOS-Integration.xcworkspace_ project file.

## Test cases

The test cases are executed against a _LOCAL_ installation of our [AeroGear TODO](https://github.com/aerogear/TODO) 'application'...

## Getting started

Open the [AeroGear-iOS-Integration.xcworkspace](aerogear-ios-integration/tree/master/AeroGear-iOS-Integration/AeroGear-iOS-Integration.xcworkspace) in Xcode, if you want to get the project...

## Running the tests

* Install JBoss
* Deploy the TODO app (make sure it's not already deployed...)
* Run the test by executing the _runTests.sh_ script
