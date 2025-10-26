source "https://github.com/CocoaPods/Specs.git"
source 'https://github.com/TuyaInc/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'
platform :ios,’12.0’
target 'AIToys' do
  pod 'Masonry', '1.1.0'
	pod 'AFNetworking', '~> 4.0'
  pod 'SDWebImage', '~> 5.1.1'
  pod 'MJRefresh', '~> 3.2.0'
  pod 'SDCycleScrollView', '~> 1.80'
  pod 'IQKeyboardManager', '~> 6.4.2'
  pod 'SVProgressHUD', '~> 2.2.5'
  pod 'FDFullscreenPopGesture', '~> 1.1'
  pod 'MBProgressHUD+JDragon','0.0.3'
  pod 'YYCategories', '~> 1.0.4'
  pod 'MJExtension', '~> 3.1.2'
  pod 'ThingSmartHomeKit', '~> 6.7.0'
  pod 'DACircularProgress'
  # 添加UI业务包
  pod 'ThingSmartHelpCenterBizBundle', '~> 6.7.0'
  pod 'ThingSmartMessageBizBundle', '~> 6.7.0'
  pod 'ThingSmartCryption', :path => './ios_core_sdk'
  # 添加MiniAPP
   pod "ThingSmartMiniAppBizBundle", '~> 6.7.0'
   pod "ThingSmartHomeKitBizBundle", '~> 6.7.0'
   #基础能力包
   pod "ThingSmartBaseKitBizBundle", '~> 6.7.0'
   #业务能力包
   pod 'ThingSmartBizKitBizBundle', '~> 6.7.0'
   # 添加设备控制 UI 业务包
   pod 'ThingSmartPanelBizBundle', '~> 6.7.0'
   pod 'ThingSmartLangsExtraBizBundle','~> 6.7.0'
   #设备控制能力包
   pod 'ThingSmartDeviceKitBizBundle', '~> 6.7.0'
   pod 'ThingBLEInterfaceImpl'
   pod 'ThingBLEMeshInterfaceImpl'
   #设备详情
   pod 'ThingSmartDeviceDetailBizBundle','~> 6.7.0'
   # 如果使用蓝牙功能，需要引入蓝牙相关组件
    pod 'ThingBluetoothInterface'
    pod 'ThingSmartShareBizBundle','~> 6.7.0'
    pod 'ThingSmartThemeManagerBizBundle','~> 6.7.0'
   #家庭管理
   pod 'ThingSmartFamilyBizBundle','~> 6.7.0'
   # 添加固件升级 UI 业务包
   pod 'ThingSmartOTABizBundle','~> 6.7.0'
#   # 添加场景业务包
#   pod 'ThingSmartSceneBizBundle','~> 6.7.0'
#   pod 'ThingSmartSceneExtendBizBundle','~> 6.7.0'
#   # 地图业务包（必需）
#   pod 'ThingSmartMapKitBizBundle'
   
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      # 请替换为您的 TeamID
      # replace to your teamid
      config.build_settings["DEVELOPMENT_TEAM"] = "GN57YVSZDP"
    end
  end
end

