//
//  AppDelegate.swift
//  Nuvo
//
//  Created by Pawel Hofman on 24/01/2021.
//

import UIKit
import SweeprMobile
import Sweepr

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Log.add(destination: ShipBookLogger(appId: "app_id", appKey: "app_key"))

    let serverConfig = SweeprServerConfiguration(url: BuildConfig.API_URL,
                                                 userAgent: BuildConfig.USER_AGENT + "/" + Bundle.main.versionString, assetsURL: BuildConfig.ASSETS_URL,
                                                 utterancesKind: .shared)
    let mqttConfig = SweeprMQTTConfiguration(port: Int(BuildConfig.MQTT_PORT) ?? 0, url: BuildConfig.MQTT_URL,
                                             login: BuildConfig.MQTT_LOGIN, password: BuildConfig.MQTT_PASSWORD,
                                             allowUntrustedCertificate: Bool(BuildConfig.MQTT_ALLOW_UNTRUSTED) ?? false,
                                             userAgent: serverConfig.userAgent)
    let config = SweeprConfiguration(serverConfig: serverConfig, mqttConfig: mqttConfig,
                                     appName: BuildConfig.APP_NAME,
                                     assetsOverwrite: .default,
                                     showMenu: true)

    #if targetEnvironment(simulator)
        SweeprClient.actionDelegate = CustomNetworkInteraction(wifi: WiFiName.simulator)
    #endif
    SweeprClient.start(with: config)
    
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    SweeprClient.didRegisterForNotifications(deviceToken)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    SweeprClient.didReceivedNotification(userInfo: userInfo, handler: completionHandler)
  }
}

