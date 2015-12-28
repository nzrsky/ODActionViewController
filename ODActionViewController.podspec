Pod::Spec.new do |s|
  s.name         = "ODActionViewController"
  s.version      = "1.1.3"
  s.summary      = "Controller for custom UIActionSheet like in Maps.app"
  s.homepage     = "https://github.com/Rogaven/ODActionViewController"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexey Nazaroff" => "alexx.nazaroff@gmail.com" }
  s.source       = { :git => "https://github.com/Rogaven/ODActionViewController.git", :tag => s.version.to_s }
  s.ios.deployment_target = '5.0'
  s.source_files = 'src/**/*'
  s.requires_arc = true
end
