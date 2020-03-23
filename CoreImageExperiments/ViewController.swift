//
//  ViewController.swift
//  CoreImageExperiments
//
//  Created by Yaroslav Spirin on 23/03/2020.
//  Copyright © 2020 Yaroslav Spirin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    private let graph = Graph(type: .standard)
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var filteredImageView: UIImageView!
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        guard let image = previewImageView.image else { return }
        guard let ciImage = CIImage(image: image) else { return }
        
        graph.process(inputImage: ciImage) { image in
            guard let image = image else { return }
            self.filteredImageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

