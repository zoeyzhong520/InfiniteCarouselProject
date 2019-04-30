//
//  ViewController.swift
//  InfiniteCarouselProject
//
//  Created by zhifu360 on 2019/4/29.
//  Copyright © 2019 ZZJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var titleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: IsSystemVersion11 ? -StatusBarHeight : 0, width: ScreenSize.width, height: 2*(StatusBarHeight+NavigationBarHeight)))
        view.backgroundColor = UIColor.cyan
        
        let label = UILabel(frame: CGRect(x: 10, y: view.bounds.size.height-40, width: 100, height: 30))
        label.text = "图片"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .white
        view.addSubview(label)
        
        return view
    }()
    
    lazy var infiniteCarouselView: InfiniteCarouselView = {
        let infiniteCarouselView = InfiniteCarouselView(frame: CGRect(x: 0, y: self.titleView.frame.maxY, width: ScreenSize.width, height: ScreenSize.width), imagesArray: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg"], isAutoScroll: true)
        return infiniteCarouselView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPage()
    }

    ///UI
    func setPage() {
        view.backgroundColor = .white
        view.addSubview(titleView)
        view.addSubview(infiniteCarouselView)
    }

}

