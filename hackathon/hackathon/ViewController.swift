//
//  ViewController.swift
//  hackathon
//
//  Created by jeffrey dinh on 4/20/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBAction func Login(sender: AnyObject) {
        if usernameTextField.text!.isEmpty && passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username and Password required."
        } else if passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Password required."
        } else if usernameTextField.text!.isEmpty {
            debugTextLabel.text = "Username required."
        } else {
            // create a session here
            debugTextLabel.text = "Login successful!"
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

