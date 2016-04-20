//
//  NLShowLocationViewController.h
//  NearlyLocation4iOS
//
//  Created by Luna Gao on 16/4/20.
//  Copyright © 2016年 luna.gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface NLShowLocationViewController : UIViewController <AMapLocationManagerDelegate, AMapSearchDelegate>


@property (weak, nonatomic) IBOutlet UITextField *searchTextField;


@end
