//
//  ViewController.swift
//  hackathon
//
//  Created by jeffrey dinh on 4/20/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//

import UIKit
let apiKey = "451fb237ae2e32421370a385d4d36303"
let getTokenMethod = "authentication/token/new"
let baseURLSecureString = "https://api.themoviedb.org/3/"
var requestToken: String?
let loginMethod = "authentication/token/validate_with_login"
let getSessionIdMethod = "authentication/session/new"
var sessionID: String?
let getUserIdMethod = "account"
var userID: Int?

class ViewController: UIViewController {

    
    @IBAction func Login(sender: UIButton) {
        if usernameTextField.text!.isEmpty && passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username and Password required."
        } else if passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Password required."
        } else if usernameTextField.text!.isEmpty {
            debugTextLabel.text = "Username required."
        } else {
            // create a session here
            debugTextLabel.text = "Login successful!"
            self.getRequestToken()
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    func getRequestToken() {
        let urlString = baseURLSecureString + getTokenMethod + "?api_key=" + apiKey
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed. (Request token.)1"
                }
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let requestToken = parsedResult["request_token"] as? String {
                    self.loginWithToken(requestToken)
                    // we will soon replace this successful block with a method call
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "got request token: \(requestToken)"
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed. (Request token.) \(requestToken)"
                    }
                    print("Could not find request_token in \(parsedResult)")
                }
            }
        }
        task.resume()
    }
 
    func loginWithToken(requestToken: String) {
        let parameters = "?api_key=\(apiKey)&request_token=\(requestToken)&username=\(self.usernameTextField.text!)&password=\(self.passwordTextField.text!)"
        let urlString = baseURLSecureString + loginMethod + parameters
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed. (Login Step.)"
                }
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let success = parsedResult["success"] as? Bool {
                    self.getSessionID(requestToken)
                    // we will soon replace this successful block with a method call
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login status: \(success)"
                    }
                } else {
                    if let status_code = parsedResult["status_code"] as? Int {
                        dispatch_async(dispatch_get_main_queue()) {
                            let message = parsedResult["status_message"]
                            self.debugTextLabel.text = "\(status_code): \(message!)"
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.debugTextLabel.text = "Login Failed. (Login Step.)"
                        }
                        print("Could not find success in \(parsedResult)")
                    }
                }
            }
        }
        task.resume()
    }
    
    func getSessionID(requestToken: String) {
        let parameters = "?api_key=\(apiKey)&request_token=\(requestToken)"
        let urlString = baseURLSecureString + getSessionIdMethod + parameters
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed. (Session ID.)"
                }
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let sessionID = parsedResult["session_id"] as? String {
                    self.getUserID(sessionID)
                    // we will soon replace this successful block with a method call
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Session ID: \(sessionID)"
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed. (Session ID.)"
                    }
                    print("Could not find session_id in \(parsedResult)")
                }
            }
        }
        task.resume()
    }
    
    func getUserID(sessionID: String) {
        let urlString = baseURLSecureString + getUserIdMethod + "?api_key=" + apiKey + "&session_id=" + sessionID
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed. (Get userID.)"
                }
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let userID = parsedResult["id"] as? Int {
                    self.completeLogin(sessionID)
                    // we will soon replace this successful block with a method call
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "your user id: \(userID)"
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed. (Get userID.)"
                    }
                    print("Could not find user id in \(parsedResult)")
                }
            }
        }
        task.resume()
    }
    
    
    func completeLogin(sessionID: String) {
        let getFavoritesMethod = "account/\(userID)/favorite/movies"
        let urlString = baseURLSecureString + getFavoritesMethod + "?api_key=\(apiKey)" + "&session_id=\(sessionID)" // take out too many + signs and use template strings. Also had to pass in sessionID
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Cannot retrieve information about user."
                }
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let results = parsedResult["results"] as? NSArray {
                    dispatch_async(dispatch_get_main_queue()) {
                        // let firstFavorite = results.lastObject as? NSDictionary
                        let title = results.valueForKey("title")
                        self.debugTextLabel.text = "Title: \(title)"
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Cannot retrieve information about user."
                    }
                    print("Could not find 'results' in \(parsedResult)")
                }
            }
        }
        task.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

