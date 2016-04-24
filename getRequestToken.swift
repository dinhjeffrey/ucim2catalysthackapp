func getRequestToken() {
    let urlString = baseURLSecureString + getTokenMethod + "?api_key=" + apiKey
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
        if let error = downloadError {
            dispatch_async(dispatch_get_main_queue()) {
                self.debugTextLabel.text = "Login Failed. (Request token.)"
            }
            print("Could not complete the request \(error)")
        } else {
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let requestToken = parsedResult["request_token"] as? String {
                self.requestToken = requestToken
                // we will soon replace this successful block with a method call

                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "got request token: \(requestToken)"
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed. (Request token.)"
                }
                print("Could not find request_token in \(parsedResult)")
            }
        }
    }
    task.resume()
}


let loginMethod = "authentication/token/validate_with_login"

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



let getSessionIdMethod = "authentication/session/new"
var sessionID: String?

func getSessionID(requestToken: String) {
    let parameters = "?api_key=\(apiKey)&request_token=\(requestToken)&username=\(self.usernameTextField.text!)&password=\(self.passwordTextField.text!)"
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
                self.sessionID = sessionID
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