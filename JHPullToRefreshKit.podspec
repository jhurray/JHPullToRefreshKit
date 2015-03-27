Pod::Spec.new do |s|
  s.name     = 'JHPullToRefreshKit'
  s.version  = '1.0.0'
  s.author   = { 'Jeff Hurray' => 'jhurray33@gmail.com' }
  s.homepage = 'https://github.com/jhurray/JHPullToRefreshKit'
  s.summary  = 'Abstract base class to easily create custom pull to refresh controls'
  s.license  = 'MIT'
  s.source   = { :git => 'https://github.com/jhurray/JHPullToRefreshKit.git', :tag => s.version.to_s }
  s.source_files = 'JHPullToRefreshKit/*.{h,m,txt}'
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end
