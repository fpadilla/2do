//
//  TodoViewCell.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 4/23/14.
//
//

#import "TodoViewCell.h"

@implementation TodoViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(18.0f , 10.0f, 22.0f, 22.0f);
}
@end
