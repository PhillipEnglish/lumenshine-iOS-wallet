//
//  AvatarTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/17/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class AvatarTableViewCell: UITableViewCell {
    
    fileprivate let _textLabel = UILabel()
    fileprivate let _imageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        contentView.addSubview(_imageView)
        _imageView.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.equalTo(separatorInset.left)
        }
        
        contentView.addSubview(_textLabel)
        _textLabel.snp.makeConstraints { make in
            make.top.equalTo(_imageView.snp.bottom).offset(10)
            make.left.equalTo(separatorInset.left)
            make.bottom.equalTo(-10)
        }
        
        _textLabel.textColor = Stylesheet.color(.white)
        _imageView.tintColor = Stylesheet.color(.white)
        
        let selection = UIView()
        selection.backgroundColor = Stylesheet.color(.whiteWith(alpha: 0.3))
        selectedBackgroundView = selection
        backgroundColor = Stylesheet.color(.clear)
    }
}

extension AvatarTableViewCell: MenuCellProtocol {
    func setText(_ text: String?) {
        _textLabel.text = text
    }
    
    func setImage(_ image: UIImage?) {
        _imageView.image = image
    }
}
