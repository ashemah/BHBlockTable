//
//  BHFetchedResultsControllerFormSection.m
//  TradieOffice
//
//  Created by Ashemah Harrison on 2/16/12.
//  Copyright (c) 2012 Boosted Human. All rights reserved.
//

#import "BHCompositeTableSectionFRC.h"
#import "BHBlockTableUtils.h"

@implementation BHCompositeTableSectionFRC

@synthesize frc = _frc;
@synthesize widgetClass;
@synthesize heightForRow;
@synthesize configureRow;
@synthesize didTapRow;
@synthesize didSwipeToDeleteRow;
@synthesize frcSourceSection;
@synthesize forceFullReloadOnDataChange;

+ (BHCompositeTableSectionFRC*)sectionForViewController:(BHCompositeTableViewController*)vc widgetClassName:(NSString*)widgetClass1 frc:(NSFetchedResultsController*)frc1 {
    return [[BHCompositeTableSectionFRC alloc] initWithViewController:vc widgetClassName:widgetClass1 frc:frc1 isHidden:NO];
}

+ (BHCompositeTableSectionFRC*)sectionForViewController:(BHCompositeTableViewController*)vc widgetClassName:(NSString*)widgetClass1 frc:(NSFetchedResultsController*)frc1 isHidden:(BOOL)isHidden {
    return [[BHCompositeTableSectionFRC alloc] initWithViewController:vc widgetClassName:widgetClass1 frc:frc1 isHidden:isHidden];
}

- (id)initWithViewController:(BHCompositeTableViewController*)formVC1 widgetClassName:(NSString*)widgetClass1 frc:(NSFetchedResultsController*)frc1 isHidden:(BOOL)isHidden {
    
    if ((self = [super initWithViewController:formVC1 isHidden:isHidden])) {
        self.widgetClass = widgetClass1;
        _frc = frc1;
        self.frc.delegate = self;
        self.frcSourceSection = 0;
        self.forceFullReloadOnDataChange = NO;
    }
    
    return self;
}

- (void)setFrc:(NSFetchedResultsController *)frc1 {
    
    if (_frc != frc1) {
        _frc = frc1;
        _frc.delegate = self;
        [self reload];
    }
}

- (NSInteger)internalRowCount {

    id <NSFetchedResultsSectionInfo> sectInfo = [[self.frc sections] objectAtIndex:0];
    NSInteger num = [sectInfo numberOfObjects];
        
    return num;
}

- (CGFloat)internalHeightForRow:(NSInteger)row {
    
    if (self.defaultRowHeight > 0) {
        return self.defaultRowHeight;
    }
    
    self.dummyCell      = [self.formVC cachedCell:self.widgetClass];
    
    if (self.heightForRow) {
        self.currentObject  = [self.frc objectAtIndexPath:[self sourceIndexPathForRow:row]];        
        self.currentRow     = row;

        self.isFirstRow = row == 0;
        self.isLastRow  = row == [self rowCount]-1;
        self.hasSingleRow = [self rowCount] == 1;
        self.isFirstSection  = self.sectionIndex == 0;
        self.isLastSection  = self.sectionIndex == [self.formVC.activeSections count]-1;
        
        return self.heightForRow(self);
    }
    
    return ((UIView*)self.dummyCell).frame.size.height;
}

- (id)internalCellForRow:(NSInteger)row {
    
    self.currentCell = [BHBlockTableUtils cachedTableCellWithClass:self.widgetClass tableView:self.formVC.tableView isNewCell:&_currentCellIsNewCell];
    
    if (self.configureRow) {
        
        self.currentObject  = [self.frc objectAtIndexPath:[self sourceIndexPathForRow:row]];
        self.currentRow     = row;

        self.isFirstRow = row == 0;
        self.isLastRow  = row == [self rowCount]-1;
        self.hasSingleRow = [self rowCount] == 1;
        self.isFirstSection  = self.sectionIndex == 0;
        self.isLastSection  = self.sectionIndex == [self.formVC.activeSections count]-1;
        
        self.configureRow(self);
    }
    
    return self.currentCell;
}

- (void)didTapRow:(NSInteger)row {
        
    if (self.didTapRow) {
        
        self.currentCell    = [self.formVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.sectionIndex]];
        self.currentObject  = [self.frc objectAtIndexPath:[self sourceIndexPathForRow:row]];
        self.currentRow     = row;

        self.isFirstRow = row == 0;
        self.isLastRow  = row == [self rowCount]-1;
        self.hasSingleRow = [self rowCount] == 1;
        self.isFirstSection  = self.sectionIndex == 0;
        self.isLastSection  = self.sectionIndex == [self.formVC.activeSections count]-1;
        
        self.didTapRow(self);
    }
}

- (void)didSwipeDeleteRow:(NSInteger)row {
        
    if (self.didSwipeToDeleteRow) {
        
        self.currentCell    = [self.formVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.sectionIndex]];
        self.currentObject  = [self.frc objectAtIndexPath:[self sourceIndexPathForRow:row]];
        self.currentRow     = row;
        
        self.isFirstRow = row == 0;
        self.isLastRow  = row == [self rowCount]-1;
        self.hasSingleRow = [self rowCount] == 1;
        self.isFirstSection  = self.sectionIndex == 0;
        self.isLastSection  = self.sectionIndex == [self.formVC.activeSections count]-1;
        
        self.didSwipeToDeleteRow(self);
        
//        [self.frc performFetch:nil];
//        [self.formVC.tableView reloadData];        
    }        
}

- (BOOL)isEditable {
    return (self.didSwipeToDeleteRow != nil);
}

- (NSIndexPath*)sourceIndexPathForRow:(NSInteger)row {
    return [NSIndexPath indexPathForRow:row inSection:self.frcSourceSection];
}

- (NSIndexPath*)virtualIndexPath:(NSIndexPath*)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:self.sectionIndex];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [self.frc objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.frcSourceSection]];
}

#pragma mark -
#pragma mark Delegates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller != self.frc) {
        return;
    }
    
    if (!self.forceFullReloadOnDataChange) {
        // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
        [self.formVC.tableView beginUpdates];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (controller != self.frc) {
        return;
    }
    
    if (self.forceFullReloadOnDataChange) {
        return;
    }
    
    // Ignore changes that are not in our section
    NSIndexPath *vIndexPath     = [self virtualIndexPath:indexPath];
    NSIndexPath *vNewIndexPath  = [self virtualIndexPath:newIndexPath];
        
    UITableView *tableView = self.formVC.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:vNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.ignoredIndexPaths addObject:indexPath];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:vIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:vIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:vNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:vIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:vNewIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (controller != self.frc) {
        return;
    }
    
    if (self.forceFullReloadOnDataChange) {
        return;
    }
    
    if (sectionIndex != self.frcSourceSection) {
        return;
    }
    
    UITableView *tableView = self.formVC.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller != self.frc) {
        return;
    }
    
//	for (UITableViewCell *cell in self.formVC.tableView.visibleCells) {
//
//		NSIndexPath *cellIndexPath = [self virtualIndexPath:[self.formVC.tableView indexPathForCell:cell]];
//
//        if ([self.ignoredIndexPaths member:cellIndexPath]) {
//            continue; // Ignore it
//        }
//        
//        self.currentCell    = cell;
//        self.currentObject  = [self.frc objectAtIndexPath:[self sourceIndexPathForRow:cellIndexPath.row]];
//        self.currentRow     = cellIndexPath.row;
//
//        self.sectionIndex   = cellIndexPath.section;
//        self.isFirstRow = cellIndexPath.row == 0;
//        self.isLastRow  = cellIndexPath.row == [self rowCount]-1;
//        self.hasSingleRow = [self rowCount] == 1;
//        self.isFirstSection  = self.sectionIndex == 0;
//        self.isLastSection  = self.sectionIndex == [self.formVC.activeSections count]-1;
//        
//        self.configureRow(self);
//    }
    
    [self.ignoredIndexPaths removeAllObjects];
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    int rowCount = [self internalRowCount];
    _isEmpty = rowCount == 0;
    
    if (self.formVC.tableView.editing || self.forceFullReloadOnDataChange) {
        [self.formVC.tableView reloadData];
    }
    else {
        [self.formVC.tableView endUpdates];        
    }
    
}

@end