Pod::Spec.new do |s|
  s.name           = "UITestHelpers"
  s.version        = "0.1.0"
  s.summary        = "UITestHelpers make UITests almost fun to write^^"
  s.description    = <<-DESC
                      UITestHelpers make UITests almost fun to write^^
                   DESC

  s.platform       = :ios, "10.0"
  s.swift_version  = "4.1"
  s.source         = { :git => "https://github.com/myposter-de/ios-ui-test-helpers.git", :tag => "#{s.version}" }
  s.homepage       = "https://github.com/myposter-de/ios-ui-test-helpers"
  s.author         = { "Martin Straub" => "martin.straub@myposter.de" }
  s.license        = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.requires_arc   = true
  s.framework      = "XCTest"
  s.source_files   = "UITestHelpers/**/*.{swift}"
end
