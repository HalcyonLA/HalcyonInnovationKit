Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '11.0'
  s.name = "HalcyonInnovationKit"
  s.module_name = "HalcyonInnovationKit"
  s.summary = "Halcyon Innovation development kit."
  s.requires_arc = true
  s.version = "1.3.35"
  s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

  s.license = { :type => "MIT", :file => "LICENSE" }
  s.homepage = "https://github.com/HalcyonLA/HalcyonInnovationKit"
  s.source = { :git => "https://github.com/HalcyonLA/HalcyonInnovationKit.git", :tag => "#{s.version}"}

  s.framework = "UIKit"
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.dependency 'HalcyonInnovationKit/UI'
    cs.dependency 'HalcyonInnovationKit/Network'
    cs.dependency 'HalcyonInnovationKit/Database'
  end

  s.subspec 'UI' do |ui|
    ui.framework = 'MapKit'
	  ui.framework = "Accelerate"
	  ui.framework = "QuartzCore"
	  ui.source_files = "Source/{UI,Extensions}/*.{swift}"
	  ui.dependency 'SDWebImage', '~> 5.0.0'
	  ui.dependency 'MBProgressHUD', '~> 1.1.0'
  end
  
  s.subspec 'Network' do |network|
	  network.source_files = "Source/Network/*.{swift}"
      network.dependency 'AFNetworking', '~> 4.0.0'
	  network.dependency 'XCGLogger', '~> 7.0.0'
	  network.dependency 'MBProgressHUD', '~> 1.1.0'
	  network.dependency 'HalcyonInnovationKit/UI'
  end
  
  s.subspec 'Database' do |database|
  	database.framework = "CoreData"
	  database.source_files = "Source/Database/*.{swift}"
	  database.dependency 'FastEasyMapping', '~> 1.2.2'
	  database.dependency 'XCGLogger', '~> 7.0.0'
	  database.dependency 'HalcyonInnovationKit/UI'
  end

  s.subspec 'Crypto' do |crypto|
    crypto.source_files = "Source/Crypto/*.{swift}"
    crypto.dependency 'HalcyonInnovationKit/Network'
    crypto.dependency 'CryptoSwift', '~> 1.0.0'
  end

end
