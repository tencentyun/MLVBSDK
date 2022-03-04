#
# Be sure to run `pod lib lint LiteAVPrivacy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LiteAVPrivacy'
  s.version          = '1.0.0'
  s.ios.deployment_target = '9.0'
  s.summary          = 'TRTC 小直播 视立方 隐私模块.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TRTC 小直播 视立方 隐私模块-个人信息展示和权限、第三方数据共享、个人信息收集清单。
                       DESC
  
  s.license      = { :type => 'Proprietary',
          :text => <<-LICENSE
            copyright 2017 tencent Ltd. All rights reserved.
            LICENSE
           }
  
  s.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  s.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  s.authors      = 'tencent video cloud'
  s.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  
  s.requires_arc = true
  s.static_framework = true
  s.source = { :git => '', :tag => "#{s.version}" }
  
  s.frameworks = 'UIKit', 'AVFoundation', 'SafariServices', 'Photos'
  s.public_header_files = 'Source/PublicHeader/**/*.h'
  s.source_files = 'Source/Localized/**/*.{h,m,mm}', 'Source/PublicHeader/*', 'Source/Config/*', 'Source/UI/**/*.{h,m,mm}', 'Source/Base/**/*.{h,m,mm}'
  s.resource_bundles = {
        'LiteAVPrivacyKitBundle' => ['Resources/localized/**/*.strings', 'Resources/*.xcassets']
  }
  
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  
  
end
