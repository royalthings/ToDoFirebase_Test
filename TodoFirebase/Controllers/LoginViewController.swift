//
//  ViewController.swift
//  TodoFirebase
//
//  Created by Дмитрий Ага on 5/28/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase


class LoginViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var warnLable: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - variable and constants
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ref = Database.database().reference(withPath: "users")
        
        //Scroll keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        // hide warning lable
        warnLable.alpha = 0
        
        //check if user already login
        Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
        
        
        let fbLoginButton = FBLoginButton(permissions: [.publicProfile, .email])
        fbLoginButton.frame = CGRect(x: 40, y: view.bounds.size.height - 50, width: 100, height: 25)
        
        fbLoginButton.delegate = self
        view.addSubview(fbLoginButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    //MARK: - Action(selector) for keyboard
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + keyboardFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrameSize.height, right: 0)
    }
    
    @objc func keyboardDidHide() {
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
    }
    
    //MARK: - func display warning lable
    func displayWarningLable(withText text: String) {
        warnLable.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: { [weak self] in
            self?.warnLable.alpha = 1
        }) { [weak self] (complete) in
            self?.warnLable.alpha = 0
        }
    }
    
    
    //MARK: - Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        //check enter email and password
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLable(withText: "Info is incorrect")
            return
        }
        // firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLable(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            self?.displayWarningLable(withText: "No such user")
        }
    }
    

    @IBAction func registerTapped(_ sender: Any) {
        //check enter email and password
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLable(withText: "Info is incorrect")
            return
        }
        //firebase create user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in

            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            //add user email to database
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
            
            
        }
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error as Any)
        }
        
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print("Failed to start graph request: ", error as Any)
                return
            }
            print(result as Any)
        }
        
        
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print("Something went wrong with our farebase user: ", error as Any)
                return
            }
            print("Successfully logged in with our user: ", user as Any)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did log out of facebook")
    }
    
    
}
