Pod::Spec.new do |s|  
    s.name              = 'ValifyEKYC'
    s.version           = '1.2.2'
    s.summary           = 'ValifyEKYC'
    s.homepage          = 'http://www.valify.me/'

    s.author            = { 'Valify' => 'sayed@valify.me' }
    s.license           = { :type => 'Valify', :file => 'LICENSE' }

    s.platform          = :ios, "11.0"
    s.swift_version = "5.0"

    s.source            = { :http => 'https://gitlab.com/Sayed.M.Obaid/valifyekyc_pods/-/raw/master/ValifyEKYC_v1.2.0-beta1.zip' }


    s.ios.deployment_target = '11.0'

    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 x86_64' }

s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}

s.dependency 'IQKeyboardManagerSwift', '6.5.9'
s.dependency 'MBProgressHUD', '1.2.0'
s.dependency 'Firebase/MLVision', '6.34'

end
