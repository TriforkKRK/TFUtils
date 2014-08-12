#
# Be sure to run `pod lib lint TFUtils.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TFUtils"
  s.version          = "0.0.2"
  s.summary          = "A set of utility classes and categories."
  s.homepage         = "https://github.com/TriforkKRK/TFUtils"
  s.license          = 'MIT'
  s.author           = { "Krzysztof Profic" => "kprofic@gmail.com" }
  s.source           = { :git => "https://github.com/TriforkKRK/TFUtils.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/**/*.{h,m}'
end
