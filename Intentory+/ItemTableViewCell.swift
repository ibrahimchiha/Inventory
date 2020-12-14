//
//  ItemTableViewCell.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 11/14/20.
//

import UIKit
import FirebaseStorage
import SDWebImage

class ItemTableViewCell: UITableViewCell {
    
    var item: InventoryItem? {
        didSet {
            guard let item = item else { return }
            
            
            itemTitleLabel.text = item.name
            stockSubtitleLabel.text = "\(item.quantity) in stock"
            
            totalPriceLabel.text = "Total Asset = $\(item.quantity * item.price)"
            
            if let picture = item.picture {
                loadImage(with: picture)
            }
        }
    }
    
    func loadImage(with uuid: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let pathReference = Storage.storage().reference(withPath: "images/\(uid)/\(uuid)")
        // Create a reference to the file you want to download
        // Fetch the download URL
        pathReference.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.itemImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "stock_item"), options: .scaleDownLargeImages, context: nil)
                self.itemImageView.contentMode = .scaleAspectFill
                self.itemImageView.clipsToBounds = true
            }
        }
        
    }
    
    let itemImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.systemGray6
        imageView.image = UIImage(named: "stock_item")
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let itemTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stockSubtitleLabel : UILabel = {
        let label = UILabel()
        label.text = "6 in stock"
        label.textColor = UIColor.systemGray2
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalPriceLabel : UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.textColor = UIColor.systemGray2
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let seeMoreButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "see_more_icon"), for: .normal)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(itemImageView)
        itemImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        itemImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        itemImageView.widthAnchor.constraint(equalToConstant: 65).isActive = true
        itemImageView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        addSubview(itemTitleLabel)
        itemTitleLabel.leftAnchor.constraint(equalTo: itemImageView.rightAnchor, constant: 8).isActive = true
        itemTitleLabel.topAnchor.constraint(equalTo: itemImageView.topAnchor).isActive = true
        itemTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        itemTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(stockSubtitleLabel)
        stockSubtitleLabel.leftAnchor.constraint(equalTo: itemTitleLabel.leftAnchor).isActive = true
        stockSubtitleLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 4).isActive = true
        stockSubtitleLabel.rightAnchor.constraint(equalTo: itemTitleLabel.rightAnchor).isActive = true
        stockSubtitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(totalPriceLabel)
        totalPriceLabel.leftAnchor.constraint(equalTo: stockSubtitleLabel.leftAnchor).isActive = true
        totalPriceLabel.topAnchor.constraint(equalTo: stockSubtitleLabel.bottomAnchor).isActive = true
        totalPriceLabel.widthAnchor.constraint(equalTo: stockSubtitleLabel.widthAnchor).isActive = true
        totalPriceLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        addSubview(seeMoreButton)
        seeMoreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        seeMoreButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        seeMoreButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        seeMoreButton.bottomAnchor.constraint(equalTo: itemImageView.bottomAnchor).isActive = true
    }
}
