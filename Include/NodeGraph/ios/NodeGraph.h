#import <UIKit/UIKit.h>

// Base classes
#import "NGNode.h"
#import "NodeInput.h"
#import "NodeOutput.h"
#import "GraphNode.h"

// Input Types
#import "NodeInputNumber.h"

// Node Implementations
#import "RGBNode.h"
#import "AssembleColorNode.h"
#import "UpdateBackgroundColorNode.h"

// Helpers
#import "NodeSerializationUtils.h"
#import "NSDictionary+NSMapTable.h"

//! Project version number for NodeGraph-ios.
FOUNDATION_EXPORT double nodeGraphVersionNumber;

//! Project version string for NodeGraph-ios.
FOUNDATION_EXPORT const unsigned char nodeGraphVersionString[];
