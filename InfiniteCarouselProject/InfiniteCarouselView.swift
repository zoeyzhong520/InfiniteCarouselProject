//
//  InfiniteCarouselView.swift
//  InfiniteCarouselProject
//
//  Created by zhifu360 on 2019/4/29.
//  Copyright © 2019 ZZJ. All rights reserved.
//

import UIKit

///无限轮播
///使用UIScrollView和三个UIImageView实现
///定时器功能可手动开启，也可自行设置间隔，默认5s
class InfiniteCarouselView: UIView {

    //MARK: - 定义属性
    
    ///图片数组
    fileprivate var imagesArray = [String]()
    
    ///isAutoScroll是否自动滚动
    fileprivate var isAutoScroll: Bool?
    
    ///duration滚动间隔
    fileprivate var duration: TimeInterval?
    
    ///当前滚动到的位置
    var index: Int = 0
    
    ///左边图片
    fileprivate lazy var leftImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.clipsToBounds = true
        image.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: self.bounds.size.height)
        return image
    }()
    
    ///中间图片
    fileprivate lazy var middleImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.clipsToBounds = true
        image.frame = CGRect(x: ScreenSize.width, y: 0, width: ScreenSize.width, height: self.bounds.size.height)
        return image
    }()
    
    ///右边图片
    fileprivate lazy var rightImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.clipsToBounds = true
        image.frame = CGRect(x: ScreenSize.width*2, y: 0, width: ScreenSize.width, height: self.bounds.size.height)
        return image
    }()
    
    ///滚动视图
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.contentOffset = CGPoint(x: ScreenSize.width, y: 0)//设置默认显示middleImage
        scrollView.contentSize = CGSize(width: ScreenSize.width*3, height: self.bounds.size.height)//设置滚动范围
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    ///滚动定时器
    fileprivate var rollTimer: Timer!
    
    //MARK: - 构建方法
    
    ///构建方法
    ///imagesArray：图片数组
    ///isAutoScroll：是否自动滚动
    ///duration：滚动间隔
    init(frame: CGRect, imagesArray: [String], isAutoScroll: Bool? = false, duration: TimeInterval? = 5) {
        super.init(frame: frame)
        self.imagesArray = imagesArray
        self.isAutoScroll = isAutoScroll
        self.duration = duration
        addViews()
    }
    
    //MARK: - Function
    
    ///UI
    func addViews() {
        addSubview(scrollView)
        scrollView.addSubview(leftImage)
        scrollView.addSubview(middleImage)
        scrollView.addSubview(rightImage)
        
        setImages()
        startRollTimer()
    }
    
    func setImages() {
        //非空判断
        if imagesArray.isEmpty {
            scrollView.isScrollEnabled = false
            return
        }
        
        //仅有一张图片
        if imagesArray.count == 1 {
            isAutoScroll = false//禁止自动滚动
            scrollView.isScrollEnabled = false
        }
        
        //图片数量超过一张
        leftImage.image = UIImage(named: imagesArray[(index-1+imagesArray.count)%imagesArray.count])
        middleImage.image = UIImage(named: imagesArray[index])
        rightImage.image = UIImage(named: imagesArray[(index+1+imagesArray.count)%imagesArray.count])
    }
    
    func reloadData() {
        //设置滚动偏移量
        scrollView.contentOffset = CGPoint(x: ScreenSize.width, y: 0)
        
        let leftIndex = (index-1+imagesArray.count)%imagesArray.count
        let rightIndex = (index+1+imagesArray.count)%imagesArray.count
        leftImage.image = UIImage(named: imagesArray[leftIndex])
        rightImage.image = UIImage(named: imagesArray[rightIndex])
        middleImage.image = UIImage(named: imagesArray[index])
    }
    
    ///创建定时器
    func startRollTimer() {
        if isAutoScroll == true && rollTimer == nil {
            //开启定时器
            rollTimer = Timer(timeInterval: duration ?? 5, target: self, selector: #selector(timerMove), userInfo: nil, repeats: true)
            RunLoop.main.add(rollTimer, forMode: .common)
        }
    }
    
    @objc func timerMove() {
        //定时器的回调方法
        //这里需要判断如果用户正在拖动屏幕或者视图正在滚动，是不可以自动翻页的，避免和用户的操作相冲突
        if !scrollView.isDragging || !scrollView.isDecelerating {
            scrollView.setContentOffset(CGPoint(x: ScreenSize.width*2, y: 0), animated: true)//设置滚动偏移量
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if rollTimer != nil {
            rollTimer.invalidate()
        }
    }
}

extension InfiniteCarouselView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //正在拖拽，停止定时器
        if rollTimer != nil {
            rollTimer.fireDate = Date.distantFuture
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //调用方法contentoffset方法动画完毕时调用次方法
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //视图静止之后，过4秒再开启定时器
        if rollTimer != nil {
            rollTimer.fireDate = Date(timeInterval: 4, since: Date())
        }
        
        let userDistance = scrollView.contentOffset.x - ScreenSize.width
        if userDistance < 0 {
            //向左滑动
            index = (index-1+imagesArray.count)%imagesArray.count
            reloadData()
        } else if userDistance > 0 {
            //向右滑动
            index = (index+1+imagesArray.count)%imagesArray.count
            reloadData()
        } else {
            //do nothing...
        }
        
    }
    
}
