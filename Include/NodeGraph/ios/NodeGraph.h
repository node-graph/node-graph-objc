#import <UIKit/UIKit.h>

// Base classes
#import "NGNode.h"
#import "NGNodeInput.h"
#import "NGNodeOutput.h"
#import "NGGraphNode.h"

// Input Types
#import "NGNodeInputNumber.h"

// Node Implementations
#import "RGBNode.h"
#import "AssembleColorNode.h"
#import "UpdateBackgroundColorNode.h"

// Helpers
#import "NGNodeSerializationUtils.h"
#import "NSDictionary+NSMapTable.h"

//! Project version number for NodeGraph-ios.
FOUNDATION_EXPORT double nodeGraphVersionNumber;

//! Project version string for NodeGraph-ios.
FOUNDATION_EXPORT const unsigned char nodeGraphVersionString[];
