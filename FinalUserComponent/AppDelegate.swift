//
//  AppDelegate.swift
//  FinalUserComponent
//
//  Created by Alesson Abao on 23/05/23.
//

import UIKit
// =====================ADDED FOR SQLITE=====================
import SQLite3

var dbQueue: OpaquePointer!
// db will be within the iOS device
var dbURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
// =====================ADDED FOR SQLITE=====================
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // =====================ADDED FOR SQLITE=====================
        // create and open db + set the pointer so it ends up finding db
        dbQueue = createAndOpenDb()
        
        if(createUserTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating User table failed 😔")
        }
        else if(insertDefaultAdmin() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Inserting default admin failed 😔")
        }
        else if(deleteDuplicateUser() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Duplicate deletion failed😔")
        }
        // =====================ADDED FOR SQLITE=====================
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // =====================ADDED FOR SQLITE=====================
    // MARK: createAndOpenDb
    func createAndOpenDb() -> OpaquePointer?{ // swift type for c pointers
        var db : OpaquePointer?
        
        let url = NSURL(fileURLWithPath: dbURL) // set up the url to db
        
        // name of db
        if let pathComponent = url.appendingPathComponent("ProductsBakery.sqlite"){
            
            let filePath = pathComponent.path
            // open sqlite db
            if sqlite3_open(filePath, &db) == SQLITE_OK{
                print("[AppDelegate.swift>createAndOpenDb] Opened the DB. File Path of db: \(filePath)")
                return db
            }
            else{
                print("[AppDelegate.swift>createAndOpenDb] Couldn't open db ☹️")
            }
        }
        else{
            print("[AppDelegate.swift>createAndOpenDb] File path unavailable.")
        }
        
        return db
    }
    
    // MARK: createUserTable
    func createUserTable() -> Bool{
        var bRetVal : Bool = false
        
        let newUsersTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS User (userID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, firstName TEXT NOT NULL, lastName TEXT NOT NULL, visuallyImpaired TEXT NOT NULL, useremail TEXT NOT NULL, userpass TEXT NOT NULL)", nil, nil, nil)
        
        if(newUsersTable != SQLITE_OK){
            print("[AppDelegate.swift>createUserTable] Cannot create new user table :(")
            bRetVal = false
        }
        else{
            bRetVal = true
        }
        
        return bRetVal
    }
    
    // MARK: insertDefaultAdmin
    func insertDefaultAdmin() -> Bool{
        var checkSuccess : Bool = false
        
        let insertDefaultAdminStatement = "INSERT INTO User (firstName, lastName, visuallyImpaired, useremail, userpass) VALUES ('Grant', 'Par', 'No', 'admin@test.com', 'admin1234')"
        
        var insertDefaultAdminStatementQuery: OpaquePointer?
        
        // ===================FOR TESTING===================
        var showData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, insertDefaultAdminStatement, -1, &insertDefaultAdminStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(insertDefaultAdminStatementQuery) == SQLITE_ROW{
                let userFirstName = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 1))
                let userLastName = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 2))
                let userVisuallyImpaired = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 3))
                let userEmail = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 4))
                let userPassword = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 5))
                
                // ===================FOR TESTING===================
                let rowData = "[AppDelegate.swift>insertDefaultAdmin] This is insertDefaultAdmin function \n" + "First Name: \(userFirstName)\t\tLast Name: \(userLastName)\t\tVisually Impaired: \(userVisuallyImpaired)\t\temail: \(userEmail)\t\tpassword: \(userPassword)\n"
                showData += rowData
                
                print(showData)
                // ===================FOR TESTING===================
            }
            print("[AppDelegate.swift>insertDefaultAdmin] Default admin inserted successfully 🥳")
            checkSuccess = true
            sqlite3_finalize(insertDefaultAdminStatementQuery)
        }
        else{
            print("[AppDelegate.swift>insertDefaultAdmin] Cannot insert default admin in User table 🙁")
            checkSuccess = false
        }
        
        return checkSuccess
    }
    
    // MARK: deleteDuplicateUser
    func deleteDuplicateUser() -> Bool{
        var checkSuccess : Bool = false
        
        let deleteDuplicateProduct = sqlite3_exec(dbQueue, "DELETE FROM User WHERE userID NOT IN (SELECT MIN(userID) FROM User GROUP BY useremail)", nil, nil, nil)
        
        
        if(deleteDuplicateProduct != SQLITE_OK){
            print("[AppDelegate.swift>deleteDuplicateUser] Cannot delete duplicate in User table 🙁")
            checkSuccess = false
        }
        else{
            print("[AppDelegate.swift>deleteDuplicateUser] User table duplicate deleted 🥳")
            checkSuccess = true
        }
        
        return checkSuccess
    }
    
    // =====================ADDED FOR SQLITE=====================
}

