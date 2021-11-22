//
//  SSOViewController.swift
//  Nuvo
//
//  Created by Pawel Hofman on 01/02/2021.
//

import Foundation
import UIKit
import SweeprMobile

class SSOViewController: UIViewController {

    private static var wasDisplayed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSweepr()
    }

    func setupSweepr() {
        SweeprClient.authenticationDelegate = self

        loginSSO()
    }

    func clearSweepr() {
        SweeprClient.view.removeFromSuperview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isBeingDismissed {
            clearSweepr()
        }
    }

    private func loginSSO() {
        if let loginURL = SweeprClient.themeManager.config.ssoConfig?.loginURL {
            self.view.addConstrained(subview: SweeprClient.view)

            if !SweeprClient.loginManager.isLoggedIn || !SSOViewController.wasDisplayed {
                //SweeprClient.loginManager.loadSSO(url: URL(string: loginURL)!)
                SweeprClient.loginManager.loadSSOLogin()
                SSOViewController.wasDisplayed = true
            }
        }
    }
}

extension SSOViewController : AuthenticationDelegate {
    func login() {
        loginSSO()
    }

    func handleSessionFailure(error: NSError) {

    }

    func logout() {
        SSOViewController.wasDisplayed = false
        SweeprClient.loginManager.logout()
        SweeprClient.clearCaches()

        if let logoutURL = SweeprClient.themeManager.config.ssoConfig?.logoutURL {
            SweeprClient.clearCookie(url: logoutURL) { (response, error) in

                DispatchQueue.main.async {
                    // just close the current view-controller, so user can return as logged-in later...
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

