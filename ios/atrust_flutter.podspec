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
  s.vendored_frameworks = 'Frameworks/SangforSDK.framework'

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'ENABLE_BITCODE' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64',
    'VALID_ARCHS' => 'arm64'
  }
end
