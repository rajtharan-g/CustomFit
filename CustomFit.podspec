#
#  Be sure to run `pod spec lint CustomFit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

spec.name         = "CustomFit"
  spec.version      = "0.0.1"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/rajtharan-g/CustomFit"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "rajtharan" => "tharanit99@gmail.com" }

  spec.ios.deployment_target = "9.0"
  spec.swift_version = "5.0"

  spec.source        = { :git => 'https://github.com/rajtharan-g/CustomFit.git', :commit => '016121d' }
  spec.source_files  = "CustomFit/*.swift"
  spec.static_framework = true
  spec.dependency "Firebase"
  spec.dependency "Firebase/Messaging"
  spec.dependency "Firebase/Auth"
  spec.dependency "Alamofire"

end
