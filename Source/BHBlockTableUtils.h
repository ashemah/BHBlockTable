//
//  BHBlockTableUtils.h
//  SunSmart
//
//  Created by Ashemah Harrison on 1/11/13.
//
//

#import <Foundation/Foundation.h>

@interface BHBlockTableUtils : NSObject

+ (id)cachedTableCellWithClass:(NSString*)cellClass tableView:(UITableView*)tableView isNewCell:(BOOL*)isNewCell;
+ (id)cachedTableCellWithClass:(NSString*)cellClass owner:(NSObject*)owner tableView:(UITableView*)tableView isNewCell:(BOOL*)isNewCell;
+ (id)loadFirstFromNIB:(NSString*)nibName;
+ (id)loadFirstFromNIB:(NSString*)nibName owner:(NSObject*)owner;

@end
