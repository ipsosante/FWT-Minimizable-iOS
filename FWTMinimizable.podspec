Pod::Spec.new do |s|
  s.name             = "FWTMinimizable"
  s.version          = "0.0.1"
  s.summary          = "A short description of FWTMinimizable."
  s.description      = <<-DESC
                       An optional longer description of FWTMinimizable

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/FutureWorkshops/FWT-Minimizable-iOS"
  s.license          = 'MIT'
  s.author           = { "Carlos Vidal" => "carlos@futureworkshops.com" }
  s.source           = { :git => "https://github.com/FutureWorkshops/FWT-Minimizable-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/carlostify'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'QuartzCore'
end
