//
//  SentMemeDetailViewController.swift
//  MyVMeme
//
//  Created by Vedarth Solutions on 6/22/18.
//  Copyright © 2018 Vedarth Solutions. All rights reserved.
//

import Foundation

import UIKit
class SentMemeDetailViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeImageView.image = meme.memedImage
        
    }
}
