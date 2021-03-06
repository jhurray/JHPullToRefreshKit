Pod::Spec.new do |s|
s.name     = 'JHPullToRefreshKit'
s.version  = '1.0.0'
s.author   = { 'https://github.com/jhurray/JHPullToRefreshKit' }
s.homepage = 'https://github.com/jhurray/JHPullToRefreshKit'
s.summary  = 'Abstract base class to easily create custom pull to refresh controls'
s.license  = 'MIT'
s.source   = { :git => 'https://github.com/jhurray/JHPullToRefreshKit.git', :tag => '1.0.0' }
s.source_files = 'JHPullToRefreshKit/*"
s.platform = :ios
s.ios.deployment_target = '7.0'
s.requires_arc = true
end