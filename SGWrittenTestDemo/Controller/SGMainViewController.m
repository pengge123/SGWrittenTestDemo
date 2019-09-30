//
//  SGMainViewController.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGMainViewController.h"
#import "SGCardCollectionVIewLayout.h"
#import "SGCardCollectionViewCell.h"
#import "SGMainViewModel.h"
#import "SGShowPictureView.h"
#define ITEMCELLID  @"ITEMCELLID"

@interface SGMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    /// 开始滑动的X坐标
    CGFloat          startX;
    /// 结束滑动的X坐标
    CGFloat          endX;
    /// cell当前位置
    NSInteger        currentIndex;
}

@property(nonatomic,strong)SGMainViewModel *mainVM;
@property(nonatomic,strong)UICollectionView *cardCollectionVIew;
/// 背景图
@property(nonatomic,strong)UIImageView *bgImageV;
/// 图片描述
@property(nonatomic,strong)UILabel *titleLabel;
/// 页码
@property(nonatomic,assign)NSInteger page;
/// 正在加载中标识
@property(nonatomic,assign)BOOL isLoading;
@end

@implementation SGMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"编辑推荐";
    self.view.backgroundColor=[UIColor whiteColor];
    //创建视图
    [self addSubView];
    // 请求第一页数据
    [self getDataWithPag:1];
}

/**
 添加子视图
 */
- (void)addSubView
{
    
    [self.view addSubview:self.bgImageV];
    [SGTools blurEffect:self.bgImageV];//设置毛玻璃效果
    [self.view addSubview:self.cardCollectionVIew];
    [self.view addSubview:self.titleLabel];

}

/**
 获取图片列表数据

 @param page 页码，从1开始
 */
- (void)getDataWithPag:(NSInteger)page
{
    if (self.isLoading) { //如果正在加载中，直接返回，防止重复请求
        return;
    }
    if (page<=1) {
        [SVProgressHUD show];
    }
    self.isLoading = YES;
    WeakSelf;
    [self.mainVM getPhotosListWithPage:page perPage:10 orderBy:(SGPhotosListOrderByPopular) successBlock:^(id  _Nonnull data) {
        [SVProgressHUD dismiss];
        weakSelf.isLoading = NO;
        [weakSelf updateView];
        weakSelf.page = page;
        
    } failBlock:^(NSString * _Nonnull errorMsg) {
        weakSelf.isLoading = NO;
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:errorMsg];
    }];
}

/**
 更新视图
 */
- (void)updateView
{
    [self.cardCollectionVIew reloadData];
    if (self.mainVM.dataAry.count>0&&self.page==0) {
        SGPageItemModel *model = self.mainVM.dataAry[0];
        [self.bgImageV sd_setImageWithURL:model.thumbUrl placeholderImage:[UIImage imageNamed:@"zhanweitu"]];
    }
}

//返回collection view里区(section)的个数，如果没有实现该方法，将默认返回1：
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//返回指定区(section)包含的数据源条目数(number of items)，该方法必须实现：
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mainVM.dataAry.count;
}

//返回自定义CollectionViewCell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SGCardCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:ITEMCELLID forIndexPath:indexPath];
    cell.model = self.mainVM.dataAry[indexPath.item];
    return cell;
}

/**
 点击每个item实现的方法
 
 @param collectionView collectionView
 @param indexPath 点击的位置
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SGShowPictureView * view = [[SGShowPictureView alloc] initWithFrame:[UIScreen mainScreen].bounds andImage:self.bgImageV.image];
    view.model = self.mainVM.dataAry[indexPath.item];
    [view show];
}

/**
 scrollView将要开始滑动

 @param scrollView  scrollView
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startX = scrollView.contentOffset.x;
    
}
/**
 scrollView结束滑动
 
 @param scrollView  scrollView
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    endX = scrollView.contentOffset.x;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self cellToCenter];
    });
}

/**
 把cell放置到中间
 */
- (void)cellToCenter
{
    //最小滚动距离
    float  dragMinDistance = self.cardCollectionVIew.bounds.size.width/20.0f;
    if (startX - endX >= dragMinDistance) {
        currentIndex -= 1; //向右
    }else if (endX - startX >= dragMinDistance){
        currentIndex += 1 ;//向左
    }
    NSInteger maxIndex  = [self.cardCollectionVIew numberOfItemsInSection:0] - 1;
    if (currentIndex<0) {
        //加载第一页数据
        [self getDataWithPag:1];
    }else if (currentIndex>maxIndex-3) {
        //加载更多数据
        [self getDataWithPag:self.page+1];
    }
    currentIndex = currentIndex <= 0 ? 0 :currentIndex;
    currentIndex = currentIndex >= maxIndex ? maxIndex : currentIndex;
    
    SGPageItemModel *model = self.mainVM.dataAry[currentIndex];
    [self.bgImageV sd_setImageWithURL:model.thumbUrl placeholderImage:[UIImage imageNamed:@"zhanweitu"]];
    self.titleLabel.text = model.title;
    [self.cardCollectionVIew scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)bgImageV
{
    if (!_bgImageV) {
        _bgImageV  = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _bgImageV.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgImageV;
}

- (UICollectionView *)cardCollectionVIew
{
    if (!_cardCollectionVIew) {
        SGCardCollectionVIewLayout *layout = [[SGCardCollectionVIewLayout alloc]init];
        _cardCollectionVIew  = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SGScreenW, SGScreenH) collectionViewLayout:layout];
        _cardCollectionVIew.delegate = self;
        _cardCollectionVIew.dataSource = self;
        _cardCollectionVIew.backgroundView = self.bgImageV;
        _cardCollectionVIew.showsHorizontalScrollIndicator = NO;
        [_cardCollectionVIew registerClass:[SGCardCollectionViewCell class] forCellWithReuseIdentifier:ITEMCELLID];
        
    }
    return _cardCollectionVIew;
}
- (SGMainViewModel *)mainVM
{
    if (!_mainVM) {
        _mainVM = [[SGMainViewModel alloc]init];
    }
    return _mainVM;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, SGScreenW-20, 100)];
        _titleLabel.text = @"编辑推荐";
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
