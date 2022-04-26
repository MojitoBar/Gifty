//
//  OptionViewController.swift
//  Gifty
//
//  Created by judongseok on 2022/04/26.
//  Copyright © 2022 Hans Knoechel. All rights reserved.
//

import UIKit

class OptionViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var imgCount: Int = 0
    var startCount: Int = 0
    var endCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTextField.keyboardType = .numberPad
        endTextField.keyboardType = .numberPad
        setUI()
    }
    
    func setUI() {
        infoLabel.text = "현재 갤러리에 사진이 \(imgCount)장 있어요."
        startTextField.text = "\(startCount)"
        endTextField.text = "\(endCount)"
        endTextField.placeholder = "\(imgCount)"
    }
}
