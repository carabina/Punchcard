Pod::Spec.new do |s|
  s.name               = "Punchcard"
  s.version            = "0.2"
  s.summary            = "Blah"
  s.homepage           = "Blah"
  s.license            = "MIT"
  s.author             = { "Josh Sklar" => "jrmsklar@gmail.com" }
  s.social_media_url   = "https://instagram.com/jrmsklar"
  s.platform           = :ios
  s.platform           = :ios, "8.2"
  s.source             = { :git => "https://github.com/stockx/Punchcard", :tag => "no version yet"}
  s.source_files       = "Source/**/*.swift"
  s.dependency           "SnapKit"
end
