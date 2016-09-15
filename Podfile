# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

abstract_target 'Panda' do
  use_frameworks!
  pod 'Birdsong', git: 'https://github.com/q231950/Birdsong.git', branch: 'swift3'
  pod 'Starscream', git: 'https://github.com/daltoniam/Starscream.git', branch: 'swift3'
  pod 'Panda', git: 'https://github.com/q231950/Panda.git'

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

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        puts "[post install] " << target.name << ":" << config.name << " updates SWIFT_VERSION to 3.0"
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
