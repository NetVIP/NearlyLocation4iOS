//
//  NLShowLocationViewController.m
//  NearlyLocation4iOS
//
//  Created by Luna Gao on 16/4/20.
//  Copyright © 2016年 luna.gao. All rights reserved.
//

#import "NLShowLocationViewController.h"

@interface NLShowLocationViewController () {
    AMapSearchAPI* _search;
    AMapPOIAroundSearchRequest *request;
}

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic) int page;

@end

@implementation NLShowLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 0;
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    request = [[AMapPOIAroundSearchRequest alloc] init];
//    request.keywords = @"方恒";
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    request.types = @"地名地址信息|体育休闲服务|科教文化服务|公共设施";
    request.sortrule = 0;
    request.requireExtension = YES;
    
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，可修改，最小2s
    self.locationManager.locationTimeout = 5;
    //   逆地理请求超时时间，可修改，最小2s
    self.locationManager.reGeocodeTimeout = 5;
    
    // 带逆地理（返回坐标和地址信息）
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
//            if (error.code == AMapLocatingErrorLocateFailed)
//            {
//                return;
//            }
        }
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
        CLLocationCoordinate2D coor = location.coordinate;
        request.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
        [_search AMapPOIAroundSearch: request];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    _search.delegate = nil;
    _search = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshLocation:(id)sender {
    self.page = 0;
    // 带逆地理（返回坐标和地址信息）
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
        CLLocationCoordinate2D coor = location.coordinate;
        request.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
        request.page = 1;
        [_search AMapPOIAroundSearch: request];
    }];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",(long)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.name];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
}

- (IBAction)loadMoreSearch:(id)sender {
    if (self.page == 0) {
        self.page = 2;
    } else {
        self.page++;
    }
    request.page = self.page;
    [_search AMapPOIAroundSearch: request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
