#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_alibc_ultimate'
  s.version          = '0.0.1'
  s.summary          = 'Flutter阿里百川旗舰版插件'
  s.description      = <<-DESC
Flutter阿里百川旗舰版插件，支持iOS和Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  # TODO: 将旗舰版SDK framework放入 Source/framework/ 目录
  s.vendored_frameworks = 'Source/framework/**/*.framework'
  s.resource = 'Source/bundle/*.bundle'
  s.platform = :ios, '9.0'
  s.frameworks = "CoreTelephony","CoreMotion","UIKit","Foundation"
  s.libraries = "z","c++","sqlite3.0"
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
