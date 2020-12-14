//
//  Extensions.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 12/13/20.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    
    func showMessage(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
