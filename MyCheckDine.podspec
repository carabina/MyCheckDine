#
# Be sure to run `pod lib lint MyCheckDine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyCheckDine'
  s.version          = '0.0.2'
s.summary          = 'A SDK that enables the developer to open a table at a restaurant, follow the order and reorder items.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'README.md'


  s.homepage         = 'http://www.mycheck.io/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'elad schiller' => 'eladsc@mycheck.co.il' }
s.source           = { :git => 'https://bitbucket.org/erez_spatz/mycheckrestaurantsdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.source_files = 'MyCheckDine/Classes/**/*'
s.dependency 'MyCheckCore'
s.dependency   'Gloss', '~> 1.1'

  # s.resource_bundles = {
  #   'MyCheckDine' => ['MyCheckDineyes/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'





end
