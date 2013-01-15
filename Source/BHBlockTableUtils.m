//
//  BHBlockTableUtils.m
//  SunSmart
//
//  Created by Ashemah Harrison on 1/11/13.
//
//

#import "BHBlockTableUtils.h"

@implementation BHBlockTableUtils

+ (id)cachedTableCellWithClass:(NSString*)cellClass tableView:(UITableView*)tableView isNewCell:(BOOL*)isNewCell {
    return [BHBlockTableUtils cachedTableCellWithClass:cellClass owner:nil tableView:tableView isNewCell:isNewCell];
}

+ (id)cachedTableCellWithClass:(NSString*)cellClass owner:(NSObject*)owner tableView:(UITableView*)tableView isNewCell:(BOOL*)isNewCell {
    
    UITableView *cell = [tableView dequeueReusableCellWithIdentifier:cellClass];
    
    if (isNewCell) {
        *isNewCell = NO;
    }
    
    if (!cell) {
        if (isNewCell) {
            *isNewCell = YES;
        }
        
        cell = [BHBlockTableUtils loadFirstFromNIB:cellClass owner:owner];
    }
    
    NSAssert(cell, @"Invalid cellClass specified");
    
    return cell;
    
}

+ (id)loadFirstFromNIB:(NSString*)nibName {
    return [BHBlockTableUtils loadFirstFromNIB:nibName owner:nil];
}

+ (id)loadFirstFromNIB:(NSString*)nibName owner:(NSObject*)owner {
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    return [nib objectAtIndex:0];
}

@end
