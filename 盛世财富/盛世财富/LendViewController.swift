//
//  ViewController.swift
//  盛世财富
//
//  Created by mo on 15-3-12.
//  Copyright (c) 2015年 sscf88. All rights reserved.
//

import UIKit

class LendViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,HttpProtocol{

    var eHttp: HttpController = HttpController()//新建一个httpController
    var base: baseClass = baseClass()
    var timeLineUrl = "http://www.sscf88.com/app-invest-content"//链接地址
    var tmpListData: NSMutableArray = NSMutableArray()//临时数据  下拉添加
    var listData: NSMutableArray = NSMutableArray()//存数据
    var page = 1 //page
    var imageCache = Dictionary<String,UIImage>()
    var tid: String = ""
    var sign: String = ""

    
    var id:String?//页面传值的id
    
    let refreshControl = UIRefreshControl() //apple自带的下拉刷新

    @IBOutlet weak var circle: UIActivityIndicatorView!//读取数据动画
    
    @IBOutlet weak var mainTable: UITableView!

    @IBOutlet weak var topImage: UIImageView!//手写的滚动图
    var timer:NSTimer?//定时器
    
    @IBOutlet weak var mainView: UIView!
    var count = 1
    func timerFunction(){
        //定时触发的方法    没用
        topImage.image = UIImage(named: String(count)+".jpg")
        count++
        if count > 4 {
            count = 1
        }
    }
    
    
    //    var dicList = Array<Dictionary<String,String>>()
    var dicList = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTable.delegate = self
        //手写的滚动图
//        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "timerFunction", userInfo: nil, repeats: true)
//        timer?.fire()
//        
//        //右划   没动画
//        var swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
//        self.view.addGestureRecognizer(swipeGesture)
//        //左划
//        var swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
//        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left //不设置是右
//        self.view.addGestureRecognizer(swipeLeftGesture)
//        
        //滚动图
        var viewsArray = NSMutableArray()
        var colorArray = [UIColor.cyanColor(),UIColor.blueColor(),UIColor.greenColor(),UIColor.yellowColor(),UIColor.purpleColor()]
        for  i in 1...4 {
            var tempImageView = UIImageView(frame:CGRectMake(0, 64, self.view.layer.frame.width, 100))//代码指定位置
            tempImageView.image = UIImage(named:"\(i).jpeg")//图片名
            tempImageView.contentMode = UIViewContentMode.ScaleAspectFill
            tempImageView.clipsToBounds = true
            viewsArray.addObject(tempImageView)//添加
            
        }
        //scrollview滚动
        var mainScorllView = YYCycleScrollView(frame:CGRectMake(0, 64, self.view.layer.frame.width, 100),animationDuration:10.0)
        mainScorllView.fetchContentViewAtIndex = {(pageIndex:Int)->UIView in
            return viewsArray.objectAtIndex(pageIndex) as UIView
        }
        
        mainScorllView.totalPagesCount = {()->Int in
            //图片的个数
            return 4;
        }
        mainScorllView.TapActionBlock = {(pageIndex:Int)->() in
            //此处根据点击的索引跳转到指定的页面
            println("点击了\(pageIndex)")
        }
        
        mainTable.tableHeaderView = mainScorllView
        
//        var ref = UIRefreshControl()
//        ref.attributedTitle = NSAttributedString(string: "下拉刷新")
//        ref.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
//        mainTable.addSubview(ref)
        
        //apple的下拉刷新
        self.refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        mainTable.addSubview(self.refreshControl)
        
        eHttp.delegate = self
        //http请求
        eHttp.get(self.timeLineUrl,viewContro :self,{
            //callback  隐藏读取动画
            self.circle.stopAnimating()
            self.circle.hidden = true
            //显示tableview
            self.mainTable.hidden = false
            self.mainTable.reloadData()
            
            
            

        })
       
//        self.setupRefresh()
        
    }
    //下拉刷新绑定的方法
    func refreshData(){
        if self.refreshControl.refreshing {
            self.refreshControl.attributedTitle = NSAttributedString(string: "加载中")
            eHttp.get(self.timeLineUrl,viewContro :self,{
                //停止下拉动画
                self.refreshControl.endRefreshing()
                self.mainTable.reloadData()
                
                
                            })
            
        }
    }
    
    
    //Refresh func
    //Refresh文件夹内开源代码
    func setupRefresh(){
        //下拉刷新
        self.mainTable.addHeaderWithCallback({
            let delayInSeconds:Int64 =  1000000000  * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.mainTable.reloadData()
                self.mainTable.headerEndRefreshing()
                
                
            })
        })
        //上啦加载
//        self.mainTable.addFooterWithCallback({
//            var nextPage = String(self.page + 1)
//            var tmpTimeLineUrl = self.timeLineUrl + "&page=" + nextPage as NSString
//            self.eHttp.delegate = self
//            self.eHttp.get(tmpTimeLineUrl)
//            let delayInSeconds:Int64 = 1000000000 * 2
//            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
//            dispatch_after(popTime, dispatch_get_main_queue(), {
//                self.mainTable.footerEndRefreshing()
//                if(self.tmpListData != self.listData){
//                    if(self.tmpListData.count != 0){
//                        var tmpListDataCount = self.tmpListData.count
//                        for(var i:Int = 0; i < tmpListDataCount; i++){
//                            self.listData.addObject(self.tmpListData[i])
//                        }
//                    }
//                    self.mainTable.reloadData()
//                    self.tmpListData.removeAllObjects()
//                }
//            })
//        })
    }
    //读取json并解析
    func didRecieveResult(result: NSDictionary){
        if(result["data"]?.valueForKey("list") != nil){
            self.tmpListData = result["data"]?.valueForKey("list") as NSMutableArray //list数据
//            self.page = result["data"]?["page"] as Int
            self.mainTable.reloadData()
        }
    }
    //高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section.hashValue == 0 {
            return 160
        }else {
            return 90
        }
    }
   
//    //划动手势
//    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
//        //划动的方向
//        var direction = sender.direction
//        //判断是上下左右
//        switch (direction){
//        case UISwipeGestureRecognizerDirection.Left:
//            
//            count++;//下标++
//            break
//        case UISwipeGestureRecognizerDirection.Right:
//            
//            count--;//下标--
//            break
//            
//        default:
//            break;
//        }
//        if count > 4{
//            count = 1
//        }
//        if count < 1 {
//            count = 4
//        }
//        //imageView显示图片
//        topImage.image = UIImage(named: "\(count).jpg")
//    }
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            var hideId = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(99) as UILabel
            id = hideId.text!
            
            //        self.presentViewController(vc, animated: true, completion: nil)
            self.performSegueWithIdentifier("detail", sender: self)
        }
        if indexPath.section == 1 {
            var user = NSUserDefaults()
            var username: NSString = user.valueForKey("username") as NSString
            if username.length > 0 {
                self.performSegueWithIdentifier("person", sender: self)
            }else{
               self.performSegueWithIdentifier("login", sender: self)
            }

            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextView:UIViewController?
        if segue.identifier == "detail"{
            var vc = segue.destinationViewController as LendDetailViewController
            vc.id = self.id
//            println(self.id)
//            println(vc.id)
        }
        if segue.identifier == "allList"{
            nextView = segue.destinationViewController as AllListViewController
        }
        //隐藏tabbar
        if nextView != nil {
            nextView!.hidesBottomBarWhenPushed = true
        }
    }
    //每个section的行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       if section.hashValue == 0 {
            return 5
        }else if section.hashValue == 1  {
            return 1
        }else{
            return 0
        }
    }
    
    //初始化cell方法
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        
        
        var sec = indexPath.section.hashValue
        var row = indexPath.row
        
        if sec == 0{
            cell = self.mainTable.dequeueReusableCellWithIdentifier("list") as UITableViewCell
            //重复的控件 必须用viewwithtag获取
            var image = cell.viewWithTag(100) as UIImageView
            var title = cell.viewWithTag(101) as UILabel
            var restMoney = cell.viewWithTag(102) as UILabel
            var restTime = cell.viewWithTag(103) as UILabel
            var period = cell.viewWithTag(104) as UILabel
            var totalMoney = cell.viewWithTag(105) as UILabel
            var percent = cell.viewWithTag(106) as UILabel
            var hideId =  UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            hideId.tag = 99
            if tmpListData.count > 0 {
                //图片  会产生阻滞
//                image.image = UIImage(data:NSData(contentsOfURL: NSURL(string: "http://www.sscf88.com/uploadData/ad/2014093013251995.jpg")!)!)
                
                title.text = tmpListData[row].valueForKey("borrow_name")! as NSString
                
//                if let a = tmpListData[row].valueForKey("need") {
//                    switch a{
//                     case let b as Double:println("Double")
//                     case let b as String:println("String")
//                    default:break
//                    }
//                }
                var d = tmpListData[row].valueForKey("need")! as Double
                restMoney.text = "\(d)元"
                restTime.text = tmpListData[row].valueForKey("leftdays")! as NSString
                
                var tmp = tmpListData[row].valueForKey("borrow_duration")! as NSString
                var unit = tmpListData[row].valueForKey("duration_unit")! as NSString
                period.text = "\(tmp)\(unit)"
                tmp = tmpListData[row].valueForKey("borrow_money")! as NSString
                totalMoney.text = "\(tmp)元"
                tmp = tmpListData[row].valueForKey("borrow_interest_rate")! as NSString
                percent.text = "\(tmp)%"
                hideId.text = tmpListData[row].valueForKey("id")! as NSString
                cell.addSubview(hideId)
                hideId.hidden = true
            }
        }
        if sec == 1{
            cell = self.mainTable.dequeueReusableCellWithIdentifier("person") as UITableViewCell
            var user = NSUserDefaults()
            var username: NSString = user.valueForKey("username") as NSString
            if username.length > 0 {
                
            }else{
                var img = cell.viewWithTag(200) as UIImageView
                var title = cell.viewWithTag(201) as UILabel
                var money = cell.viewWithTag(202) as UILabel
                title.text = "请登录"
                money.text = ""
            }
            
        }
        
//        circle.hidden = true
//        circle.stopAnimating()
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        
        
    }
    //section数量
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
        
    }
    
    //section的title
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "投资列表"
        }else if section == 1{
            return "我的账户"
        }else{
            return ""
        }
    }
    //section的header高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 130
//        }
        return 30
    }
    
    //view将要加载的时候触发的事件
    override func viewWillAppear(animated: Bool) {
        if self.tmpListData.count == 0 {
        //如果没有获取到数据 就开始动画
        mainTable.hidden = true
        circle.hidden = false
        circle.startAnimating()
        }
        println("lendView")
        //隐藏筛选
        hideSideMenuView()
    }
}
