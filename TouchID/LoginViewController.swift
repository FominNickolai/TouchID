//
//  LoginViewController.swift
//  TouchID
//
//  Created by Simon Ng on 25/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var backgroundImageView:UIImageView!
    @IBOutlet weak var loginView:UIView!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    private var imageSet = ["cloud", "coffee", "food", "pmq", "temple"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Randomly pick an image
        let selectedImageIndex = Int(arc4random_uniform(5))
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        loginView.isHidden = true
        authenticateWithTouchID()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods

    func showLoginDialog() {
        // Move the login view off screen
        loginView.isHidden = false
        loginView.transform = CGAffineTransform(translationX: 0, y: -700)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
            self.loginView.transform = CGAffineTransform.identity
            
        }, completion: nil)
        
    }
    
    func authenticateWithTouchID() {
        //Get the local authentication context
        let localAuthContext = LAContext()
        let reasonText = "Authentication is requared to sign in"
        
        var authError: NSError?
        if !localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if let error = authError {
                print(error.localizedDescription)
            }
            
            //Display the login dialog when Touch ID is not available
            showLoginDialog()
            return
        }
        
        //Perform the Touch ID authentication
        localAuthContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonText) { (success, error) in
            
            //Failure workflow
            if !success {
                if let error = error {
                    switch error {
                    case LAError.authenticationFailed:
                        print("Authentication failed")
                    case LAError.passcodeNotSet:
                        print("Passcode not set")
                    case LAError.systemCancel:
                        print("Authentication wasa canceled by system")
                    case LAError.userCancel:
                        print("Authentication was canceled by the user")
                    case LAError.touchIDNotEnrolled:
                        print("Authentication could not start because Touch ID has no enrolled fingers.")
                    case LAError.touchIDNotAvailable:
                        print("Authentication could not start because Touch ID is not available.")
                    case LAError.userFallback:
                        print("User tapped the fallback button (Enter Password).")
                    default:
                        print(error.localizedDescription)
                    }
                }
                
                //Fallback to password authentication
                OperationQueue.main.addOperation({
                    self.showLoginDialog()
                })
            } else {
                //Success workflow
                print("Successtully authenticated")
                OperationQueue.main.addOperation({
                    self.performSegue(withIdentifier: "showHomeScreen", sender: nil)
                })
            }
            
        }
    }
    
    //Actions
    @IBAction func authenticateWithPassword() {
        if emailTextField.text == "hi@giraffe.in.ua" && passwordTextField.text == "1234" {
            performSegue(withIdentifier: "showHomeScreen", sender: nil)
        } else {
            //Shake to indicate wrong login ID/password
            loginView.transform = CGAffineTransform(translationX: 25, y: 0)
            UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                self.loginView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }

}













