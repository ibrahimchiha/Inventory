//
//  Extensions.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 12/13/20.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    
    // This method presents the user with a popup AlertController
    // Takes title and message as parameters
    func showMessage(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Handle the log out of the user from Firebase and present login view
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.showMessage(with: "Error", message: error.localizedDescription)
        }
        
        if Auth.auth().currentUser == nil {
            let vc = RegisterViewController()
            // Disables Modal Dismiss functionality
            vc.isModalInPresentation = true
            self.present(vc, animated: true, completion: nil)
            return
        }
    }
    // Converts a JSON string to Dictionary (I dont think we used this but I was using it in earlier versions)
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
