//
//  RegistrationTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol RegistrationTableCellProtocol {
    func setPlaceholder(_ placeholder: String?)
    func setText(_ text: String?)
    func setSecureText(_ isSecure: Bool)
    func setInputViewOptions(_ options: [String]?, isDate: Bool?, selectedIndex: Int?)
    func setKeyboardType(_ type: UIKeyboardType)
}

typealias TextChangedClosure = (_ text:String) -> (Void)

class RegistrationTableViewCell: UITableViewCell {
    
    fileprivate let textField = TextField()
    var textEditingCallback: TextChangedClosure?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        selectionStyle = .none
        
        textField.dividerActiveColor = Stylesheet.color(.cyan)
        textField.placeholderActiveColor = Stylesheet.color(.cyan)
        textField.placeholderAnimation = .hidden
        textField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
    
    @objc
    func editingDidChange(_ textField: TextField) {
        guard let text = textField.text else {
            return
        }
        guard let callback = textEditingCallback else {
            return
        }
        callback(text)
    }

}

extension RegistrationTableViewCell: RegistrationTableCellProtocol {
    func setInputViewOptions(_ options: [String]?, isDate: Bool? = nil, selectedIndex: Int? = nil) {
        if let isdate = isDate, isdate == true {
            setDatePickerInputView()
            return
        }
        if let opt = options {
            let enumPicker = EnumPicker()
            enumPicker.setValues(opt, currentSelection: selectedIndex) { (newIndex) in
                self.textField.text = opt[newIndex]
                self.editingDidChange(self.textField)
            }
            textField.inputView = enumPicker
        } else {
            textField.inputView = nil
        }
    }
    
    func setKeyboardType(_ type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    func setPlaceholder(_ placeholder: String?) {
        textField.placeholder = placeholder
    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
    
    func setSecureText(_ isSecure: Bool) {
        textField.isSecureTextEntry = isSecure
    }
}

fileprivate extension RegistrationTableViewCell {
    func setDatePickerInputView() {
        var minYear = DateComponents()
        minYear.year = 1910
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(from: minYear)
        datePicker.addTarget(self, action: #selector(birthdayDidChange(sender:)), for: .valueChanged)
        
        textField.inputView = datePicker
    }
    
    @objc
    fileprivate func birthdayDidChange(sender: UIDatePicker) {
        textField.text = DateUtils.format(sender.date, in: .date)
        editingDidChange(textField)
    }
}
