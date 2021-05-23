//
//  SocialMediaSharingManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Social
import UIKit
import LinkPresentation

struct SocialMediaShareable {
    let id = UUID.init().uuidString
    var image:UIImage?
    var url:URL?
    var text:String?
}



struct SocialMediaSharingManage{
    
    static func share(_ object: SocialMediaShareable, for serviceType: String) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object,for: serviceType, from: vc)
    }
    
    static func share(_ object: SocialMediaShareable, for serviceType: String, from presentingVC: UIViewController) {
        if let composeVC = SLComposeViewController(forServiceType:serviceType) {
            composeVC.add(object.image)
            composeVC.add(object.url)
            composeVC.setInitialText(object.text)
            presentingVC.present(composeVC, animated: true, completion: nil)
        }
    }
    
    static func share(_ object: SocialMediaShareable) {
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        share(object, from: vc)
    }
    
    static func share(_ object: SocialMediaShareable, from presentingVC: UIViewController) {
        var sharedObjects: [AnyObject] = []
        if let img = object.image { sharedObjects.append(img) }
        if let url = object.url, let txt = object.text {
            sharedObjects.append(
                ShareActivityItemSource(url: url , icon: object.image, title: txt, isUrl: false)
            )
        }
        if let url = object.url {
            sharedObjects.append(
                ShareActivityItemSource(url: url, icon: object.image, title: object.text, isUrl: true)
            )
        }
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = presentingVC.view
        presentingVC.present(activityViewController, animated: true, completion: nil)
           
    }
}


class ShareActivityItemSource: NSObject, UIActivityItemSource {
    
    private let url: URL
    private let icon: UIImage?
    private let title: String
    private let isUrl: Bool

    init(url: URL, icon: UIImage? = nil, title: String? = nil, isUrl: Bool = true) {
        self.url = url
        self.icon = icon
        self.title = title ?? ""
        self.isUrl = isUrl
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return isUrl ? url : title
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .message {
            if isUrl {
                return self.title + "\n" + self.url.absoluteString
            } else {
                return nil
            }
        }
        return isUrl ? url : title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        if isUrl {
            return nil
        } else {
            let metadata = LPLinkMetadata()
            let shareIcon = icon ?? UIImage(named: Asset.appIcon) ?? UIImage()
            metadata.iconProvider = NSItemProvider(object: shareIcon )
            metadata.title = title
            metadata.url = url
            metadata.originalURL = url
            return metadata
        }
    }
}
