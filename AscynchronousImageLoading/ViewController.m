//
//  ViewController.m
//  AscynchronousImageLoading
//
//  Created by Rajesh's MacBook Pro  on 1/13/18.
//  Copyright © 2018 MacBook Pro Retina. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "TableItem.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ViewController{
    UIActivityIndicatorView *spinner;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:spinner];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner startAnimating];
        });
        [self loadDataFromServer];
    });
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.estimatedRowHeight = 350.0;
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    [self loadNib];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) loadNib{
    UINib *nib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [self.mTableView registerNib:nib forCellReuseIdentifier:@"CustomTableViewCell"];
}
-(void) loadDataFromServer{
    NSString *urlString = @"https://api.androidhive.info/feed/feed.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session  = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlRes = (NSHTTPURLResponse *) response;
        if(urlRes.statusCode == 200){
            NSError *err = nil;
            NSDictionary *responseDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
            NSArray *responseArray = (NSArray *)[responseDict objectForKey:@"feed"];
            [self parseJson:responseArray];
        }
    }];
    [dataTask resume];
}
-(void)parseJson:(NSArray *) response{
    self.dataArray = [[NSMutableArray alloc] init];
    if(response.count){
        for(int i=0;i<response.count;i++){
            TableItem *item = [[TableItem alloc] init];
            NSDictionary *dict = [response objectAtIndex:i];
            item.itemId = [dict valueForKey:@"id"];
            item.name = [dict valueForKey:@"name"];
            item.statusImageUrl = [dict valueForKey:@"image"] == [NSNull null] ? nil : [dict valueForKey:@"image"];
            item.status = [dict valueForKey:@"status"];
            item.timeStamp = [[dict valueForKey:@"timeStamp"] longLongValue];
            item.profieImageUrl = [dict valueForKey:@"profilePic"];
            item.url = [dict valueForKey:@"url"];
            [self.dataArray addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(spinner) [spinner stopAnimating];
            [self.mTableView reloadData];
        });
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [[CustomTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CustomTableViewCell"];
    }
    TableItem *parsedData = [self.dataArray objectAtIndex:indexPath.row];
    if (parsedData)
    {
        cell.profileImageView.image = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:parsedData.profieImageUrl]];
                                 
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CustomTableViewCell *blockCell = [tableView cellForRowAtIndexPath:indexPath];
                    blockCell.profileImageView.image = image;
                    blockCell.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
                    [blockCell setNeedsLayout];
                });
            }
        });
        
        cell.attachedImageView.image = nil;
        
        if(parsedData.statusImageUrl != nil){
            dispatch_async(queue, ^(void) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:parsedData.statusImageUrl]];
                
                UIImage* image = [[UIImage alloc] initWithData:imageData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CustomTableViewCell *blockCell = [tableView cellForRowAtIndexPath:indexPath];
                        blockCell.attachedImageView.image = image;
                        blockCell.attachedImageView.contentMode = UIViewContentModeScaleAspectFit;
                        [blockCell setNeedsLayout];
                    });
                }
            });
        }
        
    }
    cell.profileNameLabel.text = parsedData.name;
    cell.statusMessageLabel.text = parsedData.status;
    cell.statusMessageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.statusMessageLabel.numberOfLines = 0;
    cell.timeStampLabel.text = [NSString stringWithFormat:@"%lld",parsedData.timeStamp];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
@end
