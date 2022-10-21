#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk_bridge_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'idwall_sdk'
  s.version          = '1.3.0'
  s.summary          = 'The Flutter bridge of the IDwall Mobile SDK.'
  s.description      = <<-DESC
The Flutter bridge of the IDwall Mobile SDK.
                       DESC
  s.homepage         = 'https://idwall-sdk.readme.io'
  s.authors          = { 'idwall' => 'chapter.mobile@idwall.co' }
  s.license          = { :file => '../LICENSE' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework IDwallToolkit' }
  s.preserve_paths = 'IDwallToolkit.framework'
  s.vendored_frameworks = "IDwallToolkit.framework"
end
