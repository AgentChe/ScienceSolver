//
//  SLPickerView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import UIKit

final class SLPickerView: UIPickerView {
    private lazy var languages = [Language]()
    
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
extension SLPickerView {
    func setup(languages: [Language], scrollTo: Language?) {
        self.languages = languages
        
        reloadComponent(0)
        
        if let scrollTo, let row = languages.firstIndex(where: { $0 == scrollTo }) {
            selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    var selectedLanguage: Language? {
        let selectedRow = selectedRow(inComponent: 0)
        
        guard languages.indices.contains(selectedRow) else { return nil }
        
        return languages[selectedRow]
    }
}

// MARK: UIPickerViewDataSource
extension SLPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }
}

// MARK: UIPickerViewDelegate
extension SLPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        languages[row].name.attributed(with: attrs)
    }
}

// MARK: Private
private extension SLPickerView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        dataSource = self
        delegate = self
    }
}
