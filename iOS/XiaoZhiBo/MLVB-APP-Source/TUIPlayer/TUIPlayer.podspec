Pod::Spec.new do |spec|
  spec.name         = 'TUIPlayer'
  spec.version      = '1.0.0'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIPlayer'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }

  spec.dependency 'Masonry'
  spec.dependency 'TUICore'
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :git => '', :tag => "#{spec.version}" }
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.default_subspec = 'Live'

  spec.subspec 'Live' do |live|
    live.dependency 'TXLiteAVSDK_Live'
    framework_path="../../SDK/TXLiteAVSDK_Live.framework"
    live.pod_target_xcconfig={
        'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    }
    live.xcconfig = { 'HEADER_SEARCH_PATHS' => '${SRCROOT}/../SDK/TXLiteAVSDK_Live.framework/Headers/'}
    live.source_files = 'Source/Localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm,c}', 'Source/Server/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/PublicHeader/**/*.{h,m,mm}',  'Source/Common/**/*.{h,m,mm}', 'Source/Presenter/**/*.{h,m,mm}', 'Source/TUIPlayerKit_Live/*.{h,m,mm}'
    live.ios.framework = ['AVFoundation', 'Accelerate']
    live.library = 'c++', 'resolv'
    live.resource_bundles = {
      'TUIPlayerKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/*.xcassets']
    }
  end
 
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    framework_path="../../SDK/TXLiteAVSDK_Professional.framework"
    professional.pod_target_xcconfig={
        'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    }
    professional.xcconfig = { 'HEADER_SEARCH_PATHS' => '${SRCROOT}/../SDK/TXLiteAVSDK_Professional.framework/Headers/'}
    professional.source_files = 'Source/Localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm,c}', 'Source/Server/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/PublicHeader/**/*.{h,m,mm}', 'Source/Common/**/*.{h,m,mm}', 'Source/Presenter/**/*.{h,m,mm}', 'Source/TUIPlayerKit_Professional/*.{h,m,mm}'
    professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    professional.library = 'c++', 'resolv', 'sqlite3'
    professional.resource_bundles = {
      'TUIPlayerKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/*.xcassets']
    }
  end
  
  spec.subspec 'Enterprise' do |enterprise|
    enterprise.dependency 'TXLiteAVSDK_Enterprise'
    framework_path="../../SDK/TXLiteAVSDK_Enterprise.framework"
    enterprise.pod_target_xcconfig={
      'HEADER_SEARCH_PATHS'=>["$(PODS_TARGET_SRCROOT)/#{framework_path}/Headers"]
    }
    enterprise.xcconfig = { 'HEADER_SEARCH_PATHS' => '${SRCROOT}/../SDK/TXLiteAVSDK_Enterprise.framework/Headers/'}
    enterprise.source_files = 'Source/Localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm,c}', 'Source/Server/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/PublicHeader/**/*.{h,m,mm}', 'Source/Common/**/*.{h,m,mm}', 'Source/Presenter/**/*.{h,m,mm}', 'Source/TUIPlayerKit_Enterprise/*.{h,m,mm}'
    enterprise.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    enterprise.library = 'c++', 'resolv', 'sqlite3'
    enterprise.resource_bundles = {
      'TUIPlayerKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/*.xcassets']
    }
  end

  
end

