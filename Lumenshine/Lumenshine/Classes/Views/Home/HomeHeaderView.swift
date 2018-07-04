//
//  HomeHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

enum HomeHeaderViewType {
    case founded
    case unfounded
}

class HomeHeaderView: UIView {
    var type: HomeHeaderViewType! {
        didSet {
            switch type! {
            case .founded:
                showFoundedView()
            case .unfounded:
                showUnfoundedView()
            }
        }
    }
    
    var foundedView: HomeFoundedHeaderView!
    var unfoundedView: HomeUnfoundedHeaderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func showFoundedView() {
        unfoundedView.removeFromSuperview()
        
        addSubview(foundedView)
        foundedView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    private func showUnfoundedView() {
        foundedView.removeFromSuperview()
        
        addSubview(unfoundedView)
        unfoundedView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    private func setup() {
        foundedView = Bundle.main.loadNibNamed("HomeFoundedHeaderView", owner: nil, options: nil)![0] as! HomeFoundedHeaderView
        unfoundedView = Bundle.main.loadNibNamed("HomeUnfoundedHeaderView", owner: nil, options: nil)![0] as! HomeUnfoundedHeaderView
    }

}
