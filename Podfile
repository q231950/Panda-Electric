# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

abstract_target 'Pandas' do
  use_frameworks!
  pod 'Birdsong', git: 'https://github.com/sjrmanning/Birdsong.git'
  pod 'Panda', path: '../Panda'

  target 'Panda Electric' do
    project 'Panda Electric.xcodeproj'
    workspace 'Panda Electric.xcworkspace'
    platform :osx, '10.10'

    # Pods for Panda Electric

    target 'Panda ElectricTests' do
      inherit! :search_paths
      # Pods for testing
    end

    target 'Panda ElectricUITests' do
      inherit! :search_paths
      # Pods for testing
    end

  end

  target 'Panda Electric Mobile' do
      platform :ios, '9.0'
      project 'Panda Electric Mobile.xcodeproj'
      workspace 'Panda Electric Mobile.xcworkspace'

      # Pods for Panda Electric Mobile
  end
end
