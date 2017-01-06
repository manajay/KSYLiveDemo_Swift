# Uncomment the next line to define a global platform for your project
platform :ios, ‘8.0’

target 'LiveDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiveDemo

pod 'libksygpulive/libksygpulive'
pod 'SnapKit'

#转swift 3.0配置swift库的swift version = 3.0
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

end
