#
# Be sure to run `pod lib lint TwitterGifComposer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TwitterGifComposer"
  s.version          = "0.1.0"
  s.summary          = "Post gif to twitter easier."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    Native iOS twitter composer does NOT support gif. This composer will help if you need to post gifs.
                       DESC

  s.homepage         = "https://github.com/zh-wang/TwitterGifComposer"
  s.screenshots      = "http://i.imgur.com/S5Il9FE.png"
  s.license          = 'MIT'
  s.author           = { "zh-wang" => "viennakanon@gmail.com" }
  s.source           = { :git => "https://github.com/zh-wang/TwitterGifComposer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/viennakanon'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TwitterGifComposer' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'Social', 'Accounts'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
