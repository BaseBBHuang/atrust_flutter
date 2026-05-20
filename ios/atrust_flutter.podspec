#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint atrust_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'atrust_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # SangforSDK.framework 是静态 framework，必须声明 static_framework = true，
  # 否则在宿主使用 use_frameworks! 时，_OBJC_CLASS_$_SFUemSDK 不会被链接进最终二进制。
  s.static_framework = true
  s.vendored_frameworks = 'Frameworks/SangforSDK.framework'

  # SangforSDK 依赖的系统 framework / library
  s.frameworks = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration',
                 'Security', 'CFNetwork', 'CoreLocation', 'AVFoundation',
                 'CoreMedia', 'CoreGraphics', 'AudioToolbox', 'MessageUI',
                 'WebKit', 'LocalAuthentication'
  s.libraries  = 'c++', 'resolv', 'z', 'sqlite3'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64',
    'VALID_ARCHS' => 'arm64'
  }
end
