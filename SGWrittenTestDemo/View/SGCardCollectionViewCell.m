//
//  SGCardCollectionViewCell.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGCardCollectionViewCell.h"

@interface SGCardCollectionViewCell()

@property(nonatomic,strong) UIImageView *imageView;

@end

@implementation SGCardCollectionViewCell


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubviews];
        
    }
    return self;
}

-(void)addSubviews
{
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds=YES;
    [self.contentView addSubview:self.imageView];
  
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

/**
 设置数据模型

 @param model 模型
 */
- (void)setModel:(SGPageItemModel *)model
{
    _model = model;
    [self.imageView sd_setImageWithURL:model.thumbUrl placeholderImage:[UIImage imageNamed:@"zhanweitu"]];
}
@end
