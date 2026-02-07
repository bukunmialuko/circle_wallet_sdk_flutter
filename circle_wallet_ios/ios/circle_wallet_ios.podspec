#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'circle_wallet_ios'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of the circle_wallet plugin.'
  s.description      = 'iOS implementation of the circle_wallet plugin.'
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'OBKM' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '11.0'
  s.static_framework = true

  s.dependency 'Flutter'
  s.dependency 'CircleProgrammableWalletSDK_static', '1.1.9'

  s.source_files = 'Classes/**/*.{swift,h,m}'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  s.swift_version = '6.1'
end

