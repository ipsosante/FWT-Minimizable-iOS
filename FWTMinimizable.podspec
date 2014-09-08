Pod::Spec.new do |s|
  s.name             = "FWTMinimizable"
  s.version          = "0.0.1"
  s.summary          = "A cool transition which allows you to retain a view controller minimized at the bottom of the screen."
  s.description      = <<-DESC
                       A cool transition which allows you to retain a view controller minimized at the bottom of the screen.
                       DESC
  s.homepage         = "https://github.com/FutureWorkshops/FWT-Minimizable-iOS"
  s.license          = 'MIT'
  s.author           = { "Carlos Vidal" => "carlos@futureworkshops.com" }
  s.source           = { :git => "https://github.com/FutureWorkshops/FWT-Minimizable-iOS.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/carlostify'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'

  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'UIKit', 'QuartzCore'
end
