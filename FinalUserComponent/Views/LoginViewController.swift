//
//  LoginViewController.swift
//  FinalUserComponent
//
//  Created by Alesson Abao on 23/05/23.
//

import UIKit
import SQLite3

// alert function
func showMessage(message : String, buttonCaption : String, controller : UIViewController)
{
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: buttonCaption, style: .default)
    alert.addAction(action)
    controller.present(alert, animated: true)
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let customColor = hexStringToUIColor(hex: "#60390f")
        
        super.viewWillAppear(animated)
        self.emailTextField.addBottomBorderWithColor1(color: customColor, textWidth: 1.0)
        self.passwordTextField.addBottomBorderWithColor1(color: customColor, textWidth: 1.0)
    }
    
    // MARK: Action Button
    @IBAction func loginButton(_ sender: UIButton) {
        let loginEmail = emailTextField.text!
        let loginPass = passwordTextField.text!
        
        var loginSuccessful = false
        
        if validateForm(){
            let selectStatementString = "SELECT userID, useremail, userpass FROM User"
            var selectStatementQuery: OpaquePointer?
            
            // select query
            // get data
            var showData: String!
            showData = ""
            
            if sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil) == SQLITE_OK {
                // this will loop through all the rows in Users table until email and pass match in the users table
                while sqlite3_step(selectStatementQuery) == SQLITE_ROW{
                    
                    showData += "ID: " + String(cString: sqlite3_column_text(selectStatementQuery, 0)) + "\t\t" + "email: " + String(cString: sqlite3_column_text(selectStatementQuery, 1)) + "\t\t" +
                        "password: " + String(cString: sqlite3_column_text(selectStatementQuery, 2)) + "\n"
                    print(showData ?? "This is showData")
                    
                    if(loginEmail == String(cString: sqlite3_column_text(selectStatementQuery, 1)) && loginPass == String(cString: sqlite3_column_text(selectStatementQuery, 2))){
                        loginSuccessful = true
                        break
                    }
                }
                
                if(loginSuccessful){
                    showMessage(message: "Login success", buttonCaption: "Close", controller: self)
                }
                else{
                    showMessage(message: "Login failed", buttonCaption: "Try again", controller: self)
                }
                sqlite3_finalize(selectStatementQuery)
            }
            else{
                print("============================")
                print("============================")
                print("============================")
                print("============================")
                print("[LoginViewController>loginButton] something failed. !SQLITE_OK")
            }
        }
        else{
            showMessage(message: "Email and password should not be empty.", buttonCaption: "Try again", controller: self)
        }
    }
    
    // MARK: HEX COLOR
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: Form validation
    func validateForm() -> Bool{
        guard let email = emailTextField.text, !email.isEmpty else {
                return false
            }
        guard let password = passwordTextField.text, !password.isEmpty else{
            return false
        }
        return true // form is valid
    }
    
    // MARK: Frontend functions
    // dismiss keyboard when user clicks outside textbox
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // dismiss keyboard when user clicks return in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    

}
