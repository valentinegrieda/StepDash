#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "StepDashLogo" asset catalog image resource.
static NSString * const ACImageNameStepDashLogo AC_SWIFT_PRIVATE = @"StepDashLogo";

/// The "bg" asset catalog image resource.
static NSString * const ACImageNameBg AC_SWIFT_PRIVATE = @"bg";

/// The "player" asset catalog image resource.
static NSString * const ACImageNamePlayer AC_SWIFT_PRIVATE = @"player";

/// The "player_1" asset catalog image resource.
static NSString * const ACImageNamePlayer1 AC_SWIFT_PRIVATE = @"player_1";

/// The "player_2" asset catalog image resource.
static NSString * const ACImageNamePlayer2 AC_SWIFT_PRIVATE = @"player_2";

/// The "player_idle" asset catalog image resource.
static NSString * const ACImageNamePlayerIdle AC_SWIFT_PRIVATE = @"player_idle";

/// The "player_walk1" asset catalog image resource.
static NSString * const ACImageNamePlayerWalk1 AC_SWIFT_PRIVATE = @"player_walk1";

/// The "player_walk2" asset catalog image resource.
static NSString * const ACImageNamePlayerWalk2 AC_SWIFT_PRIVATE = @"player_walk2";

#undef AC_SWIFT_PRIVATE
