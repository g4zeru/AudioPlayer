//
//  RequestMediaAccessView.swift
//  AudioPlayer
//
//  Created by Haruta Yamada on 2019/06/22.
//

import UIKit

class RequestMediaAccessView: UIView {

    @IBOutlet weak var accessButton: UIButton!
    
    @IBAction func access(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
