Pod::Spec.new do |s|

s.name         = "ProductBaseClasses"
s.version      = "0.0.2"
s.summary      = "集成支付宝，微信，极光"

s.homepage     = "https://github.com/18840851520/ProductBaseClasses"
s.license      = "MIT"
s.author       = { "划落永恒" => "zjh0625@foxmail.com" }
s.platform     = :ios,'8.0'

s.source       = { :git => "https://github.com/18840851520/ProductBaseClasses.git", :tag => "#{s.version}" }
s.source_files = "ProductBaseClasses/ProductBaseClasses/**"
s.framework    = "UIKit"
s.requires_arc = true

end

