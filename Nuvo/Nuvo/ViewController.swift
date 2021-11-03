//
//  ViewController.swift
//  Nuvo
//
//  Created by Pawel Hofman on 24/01/2021.
//

import UIKit
import SweeprMobile
import Toast_Swift

class ViewController: UIViewController {
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var ssoLoginButton: UIButton!
  @IBOutlet weak var loginBtn: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userNameTextField.text = UserDefaults.standard.userName
    passwordTextField.text = UserDefaults.standard.password
    
    setupKeyboardHandling()
  }

  func setupSweepr() {
    SweeprClient.updateConfig(with: userDidRequestedLogoutHandler)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    ssoLoginButton.isHidden = SweeprClient.themeManager.config.ssoConfig == nil

    setupSweepr()
  }

  @IBAction func loginUser(_ sender: UIView) {

    let userName = userNameTextField.text ?? ""
    let password = passwordTextField.text ?? ""

    self.activityIndicator.startAnimating()
    self.activityIndicator.center = sender.center
    
    //hiding the button to show loader in it's place
    sender.isHidden = true
    
    SweeprClient.loginManager.loginAndFetchProfile(userName: userName, password: password) { (success, error) in
        self.hideLoaders(sender)
        if let error = error {
            if (error.code == 401) {
                self.view.makeToast("Invalid credentials")
            } else {
                self.view.makeToast(error.description)
            }
        } else {
            self.view.addConstrained(subview: SweeprClient.view)
        }
    }
  }

  private func hideLoaders(_ sender: UIView) {
    sender.isHidden = false
    self.activityIndicator.stopAnimating()
  }
    
  @IBAction func registerUser(_ sender: UIView) {

    let userNanme = userNameTextField.text ?? ""
    let password = passwordTextField.text ?? ""

    self.activityIndicator.startAnimating()
    self.activityIndicator.center = sender.center
    
    sender.isHidden = true

    SweeprClient.loginManager.register(email: userNanme, password: password) { (user, error) in
      if user != nil {
        SweeprClient.loginManager.loginAndFetchProfile(userName: userNanme, password: password) { (success, error) in
          self.hideLoaders(sender)
          if let error = error {
            self.view.makeToast(error.description)
          } else {
            self.view.addConstrained(subview: SweeprClient.view)
          }
        }
      } else {
          self.hideLoaders(sender)
          if let error = error {
            self.view.makeToast(error.description)
          }
      }
    }
  }
}

extension ViewController : UITextFieldDelegate {
    
    private func setupKeyboardHandling() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == userNameTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginUser(loginBtn)
        }
        
        return false
    }
}

extension ViewController {

  func userDidRequestedLogoutHandler() {
    SweeprClient.loginManager.logout()
    SweeprClient.view.removeFromSuperview()
  }
}
