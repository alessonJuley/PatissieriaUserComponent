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
            
            // =============================FOR TESTING=============================
            var showData: String!
            showData = ""
            // =============================FOR TESTING=============================
            
            if sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil) == SQLITE_OK {
                // this will loop through all the rows in Users table until email and pass match in the users table
                while sqlite3_step(selectStatementQuery) == SQLITE_ROW{
                    
                    // =============================FOR TESTING=============================
                    showData += "ID: " + String(cString: sqlite3_column_text(selectStatementQuery, 0)) + "\t\t" + "email: " + String(cString: sqlite3_column_text(selectStatementQuery, 1)) + "\t\t" +
                        "password: " + String(cString: sqlite3_column_text(selectStatementQuery, 2)) + "\n"
                    print(showData ?? "This is showData")
                    // =============================FOR TESTING=============================
                    
                    if(loginEmail == String(cString: sqlite3_column_text(selectStatementQuery, 1)) && loginPass == String(cString: sqlite3_column_text(selectStatementQuery, 2))){
                        
                        loginSuccessful = true
                        // =======ADD THIS IF YOU WANT TO DIRECT USER TO DIFFERENT VIEWCONTROLLERS BASED ON USER TYPE=======
//                        if String(cString: sqlite3_column_text(selectStatementQuery, 1)) == "admin@test.com" && String(cString: sqlite3_column_text(selectStatementQuery, 2)) == "admin1234" {
//
//                            // User is an admin, navigate to admin view controller
//                            let adminViewController = storyboard?.instantiateViewController(withIdentifier: "productViewController") as! ProductListTableViewController
//                            navigationController?.pushViewController(adminViewController, animated: true)
//
//                            // Hide the back button in the regular view controller
//                            navigationController?.setNavigationBarHidden(true, animated: false)
//                        }
//                        else if String(cString: sqlite3_column_text(selectStatementQuery, 3)) == "Yes"{
//                            // User is an admin, navigate to admin view controller
//                            let visuallyImpairedViewController = storyboard?.instantiateViewController(withIdentifier: "VisualImpairedViewController") as! VisuallyImpairedHomeViewController
//                            navigationController?.pushViewController(visuallyImpairedViewController, animated: true)
//
//                            // Hide the back button in the regular view controller
//                            navigationController?.setNavigationBarHidden(true, animated: false)
//                        }
//                        else{
//                            // User is not an admin, navigate to regular view controller
//                            let regularViewController = storyboard?.instantiateViewController(withIdentifier: "RegularViewController") as! HomeViewController
//                            navigationController?.pushViewController(regularViewController, animated: true)
//
//                            // Hide the back button in the regular view controller
//                            navigationController?.setNavigationBarHidden(true, animated: false)
//                        }
                        // =======ADD THIS IF YOU WANT TO DIRECT USER TO DIFFERENT VIEWCONTROLLERS BASED ON USER TYPE=======
                        break
                    }
                }
                
                if(loginSuccessful){
                    // =============================FOR TESTING=============================
                    // you can comment this after you add the code for directing users to different viewcontrollers based on their type
                    showMessage(message: "Login success", buttonCaption: "Close", controller: self)
                    // =============================FOR TESTING=============================
                }
                else{
                    showMessage(message: "Login failed", buttonCaption: "Try again", controller: self)
                }
                sqlite3_finalize(selectStatementQuery)
            }
            else{
                // =============================FOR TESTING=============================
                print("============================")
                print("============================")
                print("============================")
                print("============================")
                print("[LoginViewController>loginButton] something failed. !SQLITE_OK")
                // =============================FOR TESTING=============================
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
