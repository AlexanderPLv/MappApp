//
//  UIImageExt.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 28.04.2021.
//

import UIKit

extension UIImage {
    func resizeImage() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        return resizedImage
    }
}
