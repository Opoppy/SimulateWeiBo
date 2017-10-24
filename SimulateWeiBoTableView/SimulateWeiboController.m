//
//  SimulateWeiboController.m
//  SimulateWeiBoTableView
//
//  Created by 王承雨 on 2017/10/10.
//  Copyright © 2017年 wangchengyu. All rights reserved.
//

#import "SimulateWeiboController.h"

@interface SimulateWeiboController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIScrollView * scrollView;

@property(nonatomic,strong) UITableView * tableView;

@property(nonatomic,strong) UIView * bgView;

@property(nonatomic,assign) CGPoint scrollViewStartPoint;

@property(nonatomic,assign) CGPoint navBarStartPoint;

@property(nonatomic,strong) UIView * titleView;

@property(nonatomic,strong) UIView * statusBar;

@property(nonatomic,strong) UIButton * bactBtn;


@end

@implementation SimulateWeiboController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     页面的思路：先是整体在滚动，当到达具体位置之后，整体滚动停止，开始局部滚动。
     这种视图的实现方式可以是：tableView + tableView或者是scrollView + tableView 的形式，本文所讲的是scrollView + tableView 的形式，但是微博上的看结构应该是tableView + tableView实现的。
     
     实现思路：在scrollView 上添加tableView，监听scrollView的代理方法scrollViewDidScroll 当滚动到具体位置的时候将scrollView的属性scrollEnabled设置成NO，把tableView的scrollEnabled设置成YES，此时便可以看到类似微博的页面效果，但是其中有几点要注意：
     1、scrollView滚动的速度比较快，代理方法有可能没法准确的在具体的位置停下来，导致停止的位置不准确，这就需要设置scrollView的contentSize属性，scrollView停止的时候，其内容一定是滚动到了边缘，然后关掉反弹的效果，此时就可以让scrollView停止在设置好的位置上
     2.scrollView的y坐标，我这里给的是20整好在状态栏的下边，这样才能做出那种效果，我这里的navigationBar的效果是模仿简书中的文章浏览页面的效果来做的。
     */
    
    //获取状态栏的所在的View,就是在状态栏下边的白色背景
    _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    _statusBar.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:[[UIView alloc] init]];
    
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.titleView];
    
    [self.scrollView addSubview:self.tableView];
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
    
    _titleView.frame = CGRectMake(0, .5 * self.view.frame.size.height, self.view.frame.size.width, 44);
    
    _tableView.frame = CGRectMake(0, .5 * self.view.frame.size.height + 44, self.view.frame.size.width, self.view.frame.size.height - 64);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - TableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor blueColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"开始滑动");
    //记录每次刚滑动时候scrollView 的contentOffSet
    self.scrollViewStartPoint = scrollView.contentOffset;
    
    //记录navigationBar的位置
    self.navBarStartPoint = self.navigationController.navigationBar.frame.origin;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == _scrollView)
    {
        //navigationBar渐变
        [self changeNavBarWith:scrollView];
        
        //判断何时停止scorllView的滚动
        [self changeScrollViewStatueWith:scrollView];
        
        //改变状态栏的透明度
        if (self.navigationController.navigationBar.frame.origin.y == -44)
        {
            [UIView animateWithDuration:.2 animations:^{
                _statusBar.backgroundColor = [UIColor whiteColor];
            }];
        }else
        {
            [UIView animateWithDuration:.2 animations:^{
                _statusBar.backgroundColor = [UIColor clearColor];
            }];
        }
    }
}

#pragma mark - private Event
-(void)changeScrollViewStatueWith:(UIScrollView * )scrollView
{
    CGFloat stopY = _scrollView.contentSize.height - _tableView.frame.size.height - _titleView.frame.size.height;
    
    NSLog(@"%f",scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y >= stopY)
    {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, stopY);
        _scrollView.scrollEnabled = NO;

        _tableView.scrollEnabled = YES;

        _bactBtn.hidden = NO;
    }
    
    scrollView.bounces = (scrollView.contentOffset.y >= stopY) ? NO : YES;
}

-(void)changeNavBarWith:(UIScrollView * )scrollView
{
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

    //变化的区间
    if (self.navigationController.navigationBar.frame.origin.y <= 20 && self.navigationController.navigationBar.frame.origin.y >= -44)
    {
        CGFloat y = _navBarStartPoint.y - (scrollView.contentOffset.y - _scrollViewStartPoint.y) ;
        
        self.navigationController.navigationBar.frame = CGRectMake(0,y,self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);

    }
    
    //最下边停住
    if (self.navigationController.navigationBar.frame.origin.y > 20)
    {
        self.navigationController.navigationBar.frame = CGRectMake(0, 20, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    }
    
    //最上边停住
    if (self.navigationController.navigationBar.frame.origin.y < -44)
    {
        self.navigationController.navigationBar.frame = CGRectMake(0, -44, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    }
}

#pragma mark - Getter and Setter

-(UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc]init];
        
        _tableView.delegate = self;
        
        _tableView.dataSource = self;
        
        _tableView.scrollEnabled = NO;
        
        _tableView.tableFooterView = [[UITableView alloc]init];
        
    }
    return _tableView;
}
-(UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] init];
        
        _scrollView.backgroundColor = [UIColor redColor];
        
        _scrollView.delegate = self;
        
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.5 - 20);
    }
    return _scrollView;
}

-(UIView *)titleView
{
    if (_titleView == nil) {
        _titleView = [[UIView alloc] init];
        
        _titleView.backgroundColor = [UIColor orangeColor];
        
        _bactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _bactBtn.frame = CGRectMake(15, 11, 40, 20);
        
        [_bactBtn setTitle:@"返回" forState:UIControlStateNormal];
        
        _bactBtn.hidden = YES;
        
        [_bactBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_titleView addSubview:_bactBtn];
    }
    return _titleView;
}
-(void)backBtnClick
{
    //将所有的坐标都回复初始值
    [_scrollView setContentOffset:CGPointMake(0, -44) animated:YES];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 20, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    _scrollView.scrollEnabled = YES;
    
    _tableView.scrollEnabled = NO;
    
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    _bactBtn.hidden = YES;
    
    [UIView animateWithDuration:.2 animations:^{
        self.navigationController.navigationBar.frame = CGRectMake(0,20, self.view.frame.size.width, 44);
    }];
}
@end
