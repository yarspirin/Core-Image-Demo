//
//  Graph.swift
//  CoreImageExperiments
//
//  Created by Yaroslav Spirin on 23/03/2020.
//  Copyright © 2020 Yaroslav Spirin. All rights reserved.
//

import CoreImage
import Foundation
import UIKit

enum GraphType {
    case standard
}

typealias ProcessCallback = (_ image: UIImage?) -> Void

final class Graph {
    
    private let monochromeFilter: CIFilter?
    private let vignetteFilter: CIFilter?
    
    private let ciContext: CIContext?
    
    private var inputImage: CIImage?
    private var outputImage: CIImage?
    
    private let queue = DispatchQueue.global(qos: .utility)
    
    init(type: GraphType) {
        let sepiaColor = Graph.buildSepiaColor()
        
        monochromeFilter = Graph.buildMonochromeFilter(with: [
            "inputColor" : sepiaColor,
            "inputIntensity" : 1.0
        ])
        
        vignetteFilter = Graph.buildVignetteFilter(with: [
            "inputRadius" : 1.75,
            "inputIntensity" : 1.0
        ])
        
        ciContext = CIContext()
    
        inputImage = nil
        outputImage = nil
    }
    
    func process(inputImage: CIImage, completion: @escaping ProcessCallback) {
        queue.async {
            self.inputImage = inputImage
            self.monochromeFilter?.setValue(inputImage, forKey: "inputImage")
            self.vignetteFilter?.setValue(self.monochromeFilter?.outputImage, forKey: "inputImage")
            self.outputImage = self.vignetteFilter?.outputImage
            
            guard let outputImage = self.outputImage else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let uiImage = self.buildUIImage(from: outputImage) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(uiImage)
            }
        }
    }
}

fileprivate extension Graph {
    
    func buildUIImage(from ciImage: CIImage?) -> UIImage? {
        guard let ciImage = ciImage else { return nil }
        guard let ciContext = ciContext else { return nil}
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
}

fileprivate extension Graph {
    
    static func buildSepiaColor() -> CIColor {
        let color = CIColor(red: 0.76, green: 0.65, blue: 0.54)
        return color
    }
    
    static func buildMonochromeFilter(with parameters: [String : Any]?) -> CIFilter? {
        let filter = CIFilter(name: "CIColorMonochrome", parameters: parameters)
        return filter
    }
    
    static func buildVignetteFilter(with parameters: [String : Any]?) -> CIFilter? {
        let filter = CIFilter(name: "CIVignette", parameters: parameters)
        return filter
    }
}
