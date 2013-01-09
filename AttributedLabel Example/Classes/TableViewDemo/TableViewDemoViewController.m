//
//  TableViewDemoViewController.m
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import "TableViewDemoViewController.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "OHASBasicMarkupParser.h"
#import "UIAlertView+Commodity.h"
#import "OHASBasicHTMLParser.h"
#import "NSString+Base64.h"

@interface TableViewDemoViewController () <OHAttributedLabelDelegate>
@property(nonatomic, retain) NSArray* texts;
@end

static NSInteger const kAttributedLabelTag = 100;
static CGFloat const kLabelWidth = 300;
static CGFloat const kLabelVMargin = 10;

@implementation TableViewDemoViewController
@synthesize texts = _texts;

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Init/Dealloc
/////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        NSMutableArray* plainEntries = [NSMutableArray arrayWithObjects:
                                        @"哈哈哈[小声] <at>haha</at>themed @中国李sdfsdf appearances was 1983's Thriller, a Michael @Jackson short[小声] film and music [小声]video, #directed# by [抠鼻]John Landis.^^^ ",
                                   @"Visit http://www.支持中文中是apple.com *now*!",
                                   @"Go to http://www.foodreporter.net to *{red|share your food}*!",
                                   @"Start a search on http://www.google.com right now",
                                   nil];
        for(int i=0; i<100;++i)
        {
            [plainEntries addObject:[NSString stringWithFormat:@"哈哈哈<at>haha</at>[小声]themed @中文 was 1983's Thriller, a Michael @中国人 short film and music[抠鼻] video, #directed# by John Landis.^^^---- %d", i]];
        }
        [plainEntries insertObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit." \
         "Etiam pretium mi eget lectus tincidunt semper. Phasellus placerat, lorem quis laoreet." atIndex:13];
        
        NSMutableArray* formattedEntries = [NSMutableArray arrayWithCapacity:plainEntries.count];
        NSArray* randomColors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor],
                               [UIColor orangeColor], [UIColor darkTextColor], nil];
        NSUInteger idx = 0;
        for(NSString* plainEntry in plainEntries)
        {
            NSMutableAttributedString* mas = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:plainEntry];
            [mas setFont:[UIFont systemFontOfSize: (idx++ < 13) ? 18 : 16]];
            [mas setTextColor:[randomColors objectAtIndex:(idx%5)]];
            [mas setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping];
            [formattedEntries addObject:mas];
        }
        self.texts = formattedEntries;
        [self.tableView reloadData];
    }
    return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
    self.texts = nil;
    [super dealloc];
}
#endif


/////////////////////////////////////////////////////////////////////////////
#pragma mark - TableView DataSource
/////////////////////////////////////////////////////////////////////////////

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.texts count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kCellIdentifier = @"SomeCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    OHAttributedLabel* attrLabel = nil;
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        
        attrLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10,kLabelVMargin,kLabelWidth,tableView.rowHeight-2*kLabelVMargin)];
        attrLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        attrLabel.centerVertically = YES;
        attrLabel.automaticallyAddLinksForType = NSTextCheckingAllTypes;
        attrLabel.delegate = self;
        attrLabel.highlightedTextColor = [UIColor whiteColor];
        attrLabel.tag = kAttributedLabelTag;
        [cell addSubview:attrLabel];
        
#if ! __has_feature(objc_arc)
        [attrLabel release];
        [cell autorelease];
#endif
    }
    
    attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    attrLabel.attributedText = [self.texts objectAtIndex:indexPath.row];
    return cell;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - TableView Delegate
/////////////////////////////////////////////////////////////////////////////

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString* attrStr = [self.texts objectAtIndex:indexPath.row];
    CGSize sz = [attrStr sizeConstrainedToSize:CGSizeMake(kLabelWidth, CGFLOAT_MAX)];
    return sz.height + 2*kLabelVMargin;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    OHAttributedLabel* attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    
    // Detect first link and open it
    NSTextCheckingResult* firstLink = [attrLabel.linksDataDetector firstMatchInString:attrLabel.text options:0 range:NSMakeRange(0, attrLabel.text.length)];
    
    [[UIApplication sharedApplication] openURL:firstLink.extendedURL];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Method
/////////////////////////////////////////////////////////////////////////////

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    {
        return YES;
    }
    else
    {
        // Unsupported link type (especially phone links are not supported on Simulator, only on device)
        NSString *s = [[linkInfo.extendedURL absoluteString] base64DecodedString];
        [UIAlertView showWithTitle:@"Link tapped" message:[NSString stringWithFormat:@"Should open link: %@",s]  ];
        return NO;
    }
}

@end
