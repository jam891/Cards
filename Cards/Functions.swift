//
//  Functions.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation

func imageResize(image: UIImage, sizeChange: CGSize) -> UIImage {
    let hasAlpha = true
    let scale: CGFloat = 0.0
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage
}