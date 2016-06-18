//
//  ViewController.m
//  Demo
//
//  Created by cloud on 6/18/16.
//  Copyright © 2016 yedaoinc. All rights reserved.
//

#import "ViewController.h"
typedef void (^Block)();

@interface TreeNode : NSObject
@property (strong, nonatomic) NSString* nodeTitle;//key
@property (strong, nonatomic) NSArray<TreeNode*>* subNodes;//value, null able
@property (assign, nonatomic, getter=isOpen) BOOL open;
@property (assign, nonatomic) CGFloat height;
@end
@implementation TreeNode
+(instancetype)parserWithObject:(id)object
{
    TreeNode* rootNode = [[[self class]alloc]init];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        rootNode.nodeTitle = [[object allKeys] firstObject];// set key
        id subNodes = [object objectForKey:rootNode.nodeTitle];
        NSMutableArray* subNodeArr = @[].mutableCopy;
        if ([subNodes isKindOfClass:[NSDictionary class]])
        {
            NSArray* allKeys = [subNodes allKeys];
            for (NSString* nodeKey in allKeys)
            {
                id subNode = [self parserWithObject:@{nodeKey:[subNodes objectForKey:nodeKey]}];
                if (subNode)
                {
                    [subNodeArr addObject:subNode];
                }
            }
        }
        if ([subNodes isKindOfClass:[NSArray class]])
        {
            for (id obj in subNodes)
            {
                id subNode = [self parserWithObject:obj];
                if (subNode)
                {
                    [subNodeArr addObject:subNode];
                }
            }
        }
        if (subNodeArr.count>0)
        {
            rootNode.subNodes = subNodeArr;
        }
        return rootNode;
    }
    if ([object isKindOfClass:[NSArray class]])
    {
        NSMutableArray* subNodeArr = @[].mutableCopy;
        for (NSString* nodeKey in object)
        {
            id subNode = [self parserWithObject:nodeKey];
            if (subNode)
            {
                [subNodeArr addObject:subNode];
            }
        }
        if (subNodeArr.count>0)
        {
            rootNode.subNodes = subNodeArr;
        }
        return rootNode;
    }
    if ([object isKindOfClass:[NSString class]])
    {
        rootNode.nodeTitle = object;
        return rootNode;
    }
    return nil;
}
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.open = NO;
    }
    return self;
}
+(CGFloat)getCurrentNodeHeightWithTreeNode:(TreeNode*)treeNode
{
    CGFloat height = 0.f;
    if (treeNode.isOpen)
    {
        if (treeNode.subNodes)
        {
            for (TreeNode* subNode in treeNode.subNodes)
            {
                height += [self getCurrentNodeHeightWithTreeNode:subNode];
            }
            height += 20.f;
            return height;
        }
    }
    else
    {
        height += 20.f;
        return height;
    }
    return 0.f;
}
@end

@interface TableViewHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) TreeNode* treeNode;
@property (strong, nonatomic) UIButton* sender;
@end
@implementation TableViewHeader
static NSString* tableviewheader = @"tableviewheader";
+(instancetype)tableViewHeaderWithTableView:(UITableView*)tableView
{
    id header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:tableviewheader];
    if (header == nil)
    {
        header = [[[self class]alloc]initWithReuseIdentifier:tableviewheader];
    }
    return header;
}
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.label = [[UILabel alloc]init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.label];
        UIButton* sender = [[UIButton alloc]init];
        [sender addTarget:self
                   action:@selector(tapHeaderView:)
         forControlEvents:UIControlEventTouchUpInside];
        sender.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:sender];
        self.sender = sender;
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.label
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.label
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.label
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.label
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:sender
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:sender
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:sender
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:sender
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1
                                                             constant:0]]];
    }
    return self;
}
-(void)setTreeNode:(TreeNode *)treeNode
{
    _treeNode = treeNode;
    _label.text = _treeNode.nodeTitle;
    _sender.enabled = _treeNode.subNodes?YES:NO;
}
-(void)tapHeaderView:(id)sender
{
    self.treeNode.open = !self.treeNode.isOpen;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reload" object:nil];
}
@end

@interface TableViewCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) TreeNode* treeNode;
@end
@implementation TableViewCell
static NSString* tableviewcell = @"tableviewcell";
+(instancetype)tableViewCellWithTableView:(UITableView*)tableView
{
    id cell = [tableView dequeueReusableCellWithIdentifier:tableviewcell];
    if (cell == nil)
    {
        cell = [[[self class] alloc]initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:tableviewcell];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(reload)
                                                    name:@"reload"
                                                  object:nil];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero
                                                     style:UITableViewStylePlain];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.contentView addSubview:self.tableView];
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.tableView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.tableView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.tableView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.tableView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1
                                                             constant:0]]];
    }
    return self;
}
-(void)setTreeNode:(TreeNode *)treeNode
{
    _treeNode = treeNode;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.treeNode.isOpen)
    {
        return self.treeNode.subNodes?self.treeNode.subNodes.count:0;
    }
    return 0;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell* cell = [TableViewCell tableViewCellWithTableView:tableView];
    cell.treeNode = self.treeNode.subNodes[indexPath.row];
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableViewHeader* headerView = [TableViewHeader tableViewHeaderWithTableView:tableView];
    headerView.treeNode = self.treeNode;
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TreeNode getCurrentNodeHeightWithTreeNode:self.treeNode.subNodes[indexPath.row]];
}
-(void)reload
{
    [self.tableView reloadData];
}
@end


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) TreeNode* treeNode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary*dic = @{@"1.Root":@{@"2.Device":@{@"3.Mobile":@[@"4.iOS",
                                                                 @"4.Window",
                                                                 @"4.Android"],
                                                   @"3.Mac":@[@"4.Mac mini",
                                                              @"4.Macbook Pro",
                                                              @"4.iMac"]},
                                     @"2.Friend":@{@"3.Colleague":@[@"4.Zhangsan",
                                                                    @"4.Lisi",
                                                                    @"4.Wangwu"],
                                                   @"3.Classmate":@[@"4.Qianba",
                                                                    @"4.Zhaoliu"]}}};
    self.treeNode = [TreeNode parserWithObject:dic];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero
                                                 style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.tableView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.tableView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.tableView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.tableView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:64]]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reload)
                                                name:@"reload"
                                              object:nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell* cell = [TableViewCell tableViewCellWithTableView:tableView];
    cell.treeNode = self.treeNode;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%lf",[TreeNode getCurrentNodeHeightWithTreeNode:self.treeNode]);
    return [TreeNode getCurrentNodeHeightWithTreeNode:self.treeNode];
}
-(void)setTreeNode:(TreeNode *)treeNode
{
    _treeNode = treeNode;
}
-(void)reload
{
    [self.tableView reloadData];
}

@end
