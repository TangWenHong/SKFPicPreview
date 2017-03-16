//
//  SKFPicPreViewController.m
//  SKFPicPreview
//
//  Created by 孙凯峰 on 2017/3/15.
//  Copyright © 2017年 wubianxiaoxian. All rights reserved.
//

#import "SKFPicPreViewController.h"
//#import "NewkPhotoPreviewCell.h"
#import "SKFPreviweCell.h"
#import "UIView+layoutnew.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SKFPreViewNavController.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
@interface SKFPicPreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    BOOL _isHideNaviBar;
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_displayLabel;
    UIView *_toolBar;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
}

@end

@implementation SKFPicPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCollectionView];
    [self configCustomNaviBar];
}

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    self.photosTemp = photos;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.kf_width) * _currentIndex, 0) animated:NO];
    //    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)configCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.kf_width, 64)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    _naviBar.alpha = 0.7;
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    _displayLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.kf_width/2-25, 20, 50, 18)];
    _displayLabel.text=[NSString stringWithFormat:@"%ld/%zd",_currentIndex+1,self.photos.count];
    
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    _displayLabel.textColor=[UIColor whiteColor];
    _displayLabel.font=[UIFont systemFontOfSize:18];
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.kf_width - 54, 10, 42, 42)];
    [_selectButton setTitle:@"删除" forState:UIControlStateNormal];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:_selectButton];
    if (self.NewTZPreviewisDelete) {
        _selectButton.hidden=YES;
    }
    [_naviBar addSubview:_backButton];
    [_naviBar addSubview:_displayLabel];
    [self.view addSubview:_naviBar];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.kf_width, self.view.kf_height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.kf_width , self.view.kf_height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.view.kf_width * _photos.count, self.view.kf_height);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[SKFPreviweCell class] forCellWithReuseIdentifier:@"SKFPreviweCell"];
}

#pragma mark - Click Event
- (IBAction)PushQuestionBack:(id)sender {
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        NSLog(@"我点击了取消");
    }
    else if (buttonIndex==1){
        NSLog(@"删除前self.photos %@ self.photosTemp[_currentIndex]%@  _currentIndex %ld",self.photos,self.photosTemp[_currentIndex],(long)_currentIndex);
        [self.photos removeObject:self.photosTemp[_currentIndex]];
        
        [self okButtonClick];
        
        
    }
}
- (void)select:(UIButton *)selectButton {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你确实要删除这张图片吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

- (void)back {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)okButtonClick {
    if (self.photos.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    if (self.okButtonClickBlockWithPreviewType) {
        
        self.okButtonClickBlockWithPreviewType(self.photos);
        _displayLabel.text=[NSString stringWithFormat:@"%ld/%zd",_currentIndex+1,self.photos.count];
        
        [_collectionView reloadData];
        
    }
    
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offSet = scrollView.contentOffset;
    _currentIndex = (offSet.x + (self.view.kf_width * 0.5)) / self.view.kf_width;
    NSLog(@"当前页_currentIndex %ld",(long)_currentIndex);
    _displayLabel.text=[NSString stringWithFormat:@"%ld/%zd",_currentIndex+1,self.photos.count];
    
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SKFPreviweCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SKFPreviweCell" forIndexPath:indexPath];
    if (self.IsNative) {
        NSLog(@"加载本地图片");
        [cell setKNativeImageview:self.photos[indexPath.row]];
    }
    
    else{
        NSLog(@"加网络图片");
        
        [cell setKImageView:self.photos[indexPath.row]];
        
    }
    //
    __block BOOL _weakIsHideNaviBar = _isHideNaviBar;
    __weak typeof(_naviBar) weakNaviBar = _naviBar;
    __weak typeof(_toolBar) weakToolBar = _toolBar;
    if (!cell.singleTapGestureBlock) {
        cell.singleTapGestureBlock = ^(){
            // show or hide naviBar / 显示或隐藏导航栏
            _weakIsHideNaviBar = !_weakIsHideNaviBar;
            weakNaviBar.hidden = _weakIsHideNaviBar;
            weakToolBar.hidden = _weakIsHideNaviBar;
        };
    }
    return cell;
}


@end