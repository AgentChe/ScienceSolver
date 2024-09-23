//
//  SWMPickerView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import UIKit

final class SWMPickerView: UIPickerView {
    private lazy var styles: [WritingStyle] = WritingStyle.allCases
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.medium(size: 18.scale))
        .lineHeight(32.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SWMPickerView {
    func select(style: WritingStyle) {
        if let row = styles.firstIndex(where: { $0 == style }) {
            selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    var selectedStyle: WritingStyle? {
        let selectedRow = selectedRow(inComponent: 0)
        
        guard styles.indices.contains(selectedRow) else { return nil }
        
        return styles[selectedRow]
    }
}

// MARK: UIPickerViewDataSource
extension SWMPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        styles.count
    }
}

// MARK: UIPickerViewDelegate
extension SWMPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        styles[row].title.attributed(with: attrs)
    }
}

// MARK: Private
private extension SWMPickerView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        dataSource = self
        delegate = self
    }
}

// MARK: Additiona;
private extension WritingStyle {
    var title: String {
        switch self {
        case .expository:
            return "WritingStyle.Expository".localized
        case .narrative:
            return "WritingStyle.Narrative".localized
        case .argumentative:
            return "WritingStyle.Argumentative".localized
        case .analytical:
            return "WritingStyle.Analytical".localized
        case .research:
            return "WritingStyle.Research".localized
        case .descriptive:
            return "WritingStyle.Descriptive".localized
        case .omparative:
            return "WritingStyle.Omparative".localized
        case .other:
            return "WritingStyle.Other".localized
        }
    }
}
