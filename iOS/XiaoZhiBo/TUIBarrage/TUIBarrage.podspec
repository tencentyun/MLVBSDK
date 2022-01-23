#
# Be sure to run `pod lib lint TUIBarrage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'TUIBarrage'
  spec.version          = '1.0.0'
  spec.summary          = 'A short description of TUIBarrage.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

spec.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  spec.homepage         = 'https://github.com/wesleylei/TUIBarrage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'wesleylei' => 'wesleylei@tencent.com' }
  spec.source           = { :git => 'https://github.com/wesleylei/TUIBarrage.git', :tag => spec.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.ios.deployment_target = '9.0'
  spec.requires_arc = true
  spec.static_framework = true
  
  spec.source_files = 'Source/Localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/Service/**/*.{h,m,mm}', 'Source/TUIExtension/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}'
  spec.resource_bundles = {
      'TUIBarrageBundle' => ['Resources/Localized/**/*.strings','Resources/*.xcassets']
  }
  
  
  #  依赖内部库
  spec.dependency 'TUICore'
  spec.dependency 'TXIMSDK_Plus_iOS'
  
  #  OC第三方库
  spec.dependency 'Masonry'
  spec.dependency 'SDWebImage'
  spec.dependency 'MJExtension'
end
