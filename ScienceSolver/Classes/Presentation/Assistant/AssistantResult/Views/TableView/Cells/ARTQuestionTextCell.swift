//
//  ARTQuestionTextCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class ARTQuestionTextCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ARTQuestionTextCell {
    func setup() {
        
    }
}

// MARK: Private
private extension ARTQuestionTextCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ARTQuestionTextCell {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension ARTQuestionTextCell {
    
}
