//
//  NLShowLocationTableViewController.m
//  NearlyLocation4iOS
//
//  Created by Luna Gao on 16/4/20.
//  Copyright © 2016年 luna.gao. All rights reserved.
//

#import "NLShowLocationTableViewController.h"

@interface NLShowLocationTableViewController (){
    AMapSearchAPI* _search;
    AMapPOIAroundSearchRequest *request;
}

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic) int page;
@property (nonatomic, strong) NSMutableArray<AMapPOI *> *locationArray;

@end

@implementation NLShowLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    self.page = 1;
    self.locationArray = [[NSMutableArray alloc] init];
    [self sendRequest];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadNewData {
    [self.locationArray removeAllObjects];
    [self.tableView reloadData];
    self.page = 1;
    request.page = self.page;
    [_search AMapPOIAroundSearch: request];
}

- (void)loadMoreData {
    self.page ++;
    request.page = self.page;
    [_search AMapPOIAroundSearch: request];
}

- (void)stopLoadingView {
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
    
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
    }
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count != 0)
    {
        for (AMapPOI *p in response.pois) {
            [self.locationArray addObject:p];
        }
    }
    [self.tableView reloadData];
    [self stopLoadingView];
}

- (void) sendRequest {
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    request = [[AMapPOIAroundSearchRequest alloc] init];
    request.keywords = nil;
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    request.types = @"地名地址信息|体育休闲服务|科教文化服务|公共设施";
    request.sortrule = 0;
    request.requireExtension = YES;
    request.page = self.page;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.locationArray) {
        return self.locationArray.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    }
    AMapPOI *location = self.locationArray[indexPath.row];
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = location.address;
    
    return cell;
}

@end
