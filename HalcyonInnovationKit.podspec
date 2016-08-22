Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HalcyonInnovationKit"
s.module_name = "HalcyonInnovationKit"
s.summary = "Halcyon Innovation development kit."
s.requires_arc = true
s.version = "1.0.31"
s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = "https://github.com/HalcyonLA/HalcyonInnovationKit"
s.source = { :git => "https://github.com/HalcyonLA/HalcyonInnovationKit.git", :tag => "#{s.version}"}

s.framework = "UIKit"
s.framework = "QuartzCore"
s.framework = "Accelerate"
s.framework = "CoreData"
s.framework = "MapKit"

s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FastEasyMapping', '~> 1.0.2'
s.dependency 'MBProgressHUD', '~> 1.0.0'
s.dependency 'SDWebImage', '~> 3.8.1'
s.dependency 'XCGLogger', '~> 3.4'

s.source_files = "Source/**/*.{swift,h,m}"

end