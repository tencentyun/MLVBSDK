#
# Be sure to run `pod lib lint TUIGift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guidespec.cocoapodspec.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'TUIGift'
  spec.version          = '1.0.0'
  spec.summary          = 'A short description of TUIGift.'

# This description is used to generate tags and improve search resultspec.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  spec.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  spec.homepage         = 'https://github.com/wesleylei/TUIGift'
  # spec.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'wesleylei' => 'wesleylei@tencent.com' }
  spec.source           = { :git => 'https://github.com/wesleylei/TUIGift.git', :tag => spec.version.to_s }
  # spec.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.ios.deployment_target = '9.0'
  
  spec.dependency 'TXIMSDK_Plus_iOS'
  framework_path="../../SDK/TXIMSDK_Plus_iOS.framework"
  spec.pod_target_xcconfig={
      'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
  }
  spec.source_files = 'Source/localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/Service/**/*.{h,m,mm}', 'Source/TUIExtension/**/*.{h,m,mm}','Source/UI/**/*.{h,m,mm}'
  spec.resource_bundles = {
      'TUIGiftBundle' => ['Resources/Localized/**/*.strings','Resources/*.xcassets']
  }
  
  #  依赖内部库
  spec.dependency 'TUICore'
  #  OC第三方库
  spec.dependency 'Masonry'
  spec.dependency 'SDWebImage'
  spec.dependency 'lottie-ios', '~> 2.5.3'
end
