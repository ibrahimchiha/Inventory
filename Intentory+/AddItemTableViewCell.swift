//
//  AddItemTableViewCell.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 11/14/20.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var createNewButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create New", for: .normal)
        button.setImage(UIImage(named: "add_item"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.isUserInteractionEnabled = true
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
    private func setupView() {
        selectionStyle = .none
        addSubview(createNewButton)
        
        createNewButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        createNewButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        createNewButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2).isActive = true
        createNewButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
