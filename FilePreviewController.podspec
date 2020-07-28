#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'FilePreviewController'
  s.version          = '1.0.2'
  s.summary          = 'Enpand QLPreviewController to support remote file preview. Use Alamofire as a dependency to load file.'
  s.description      = <<-DESC
  Enpand QLPreviewController to support remote file preview. Use Alamofire as a dependency to load file.
                       DESC

  s.homepage         = 'https://github.com/teambition/FilePreviewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/FilePreviewController.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'FilePreviewController/*.swift', 'FilePreviewController/*.{h,m}'
  s.ios.resource_bundle = { 'Images' => 'FilePreviewController/Images.xcassets' }

  s.dependency 'Alamofire', '~> 4.8'

end
