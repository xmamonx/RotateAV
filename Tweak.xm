// By @CrazyMind90

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>


#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wprotocol"
#pragma GCC diagnostic ignored "-Wmacro-redefined"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunknown-warning-option"
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"


 

#define rgbValue
#define UIColorFromHEX(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


 
UIButton *InitButtonWithName(NSString *BuName, UIView *View, id Target,SEL Action){

UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
[Button setTitle:BuName forState:UIControlStateNormal];
[Button addTarget:Target action:Action forControlEvents:UIControlEventTouchUpInside];
[View addSubview:Button];

  return Button;
}
 
 

@interface SBControlCenterSystemAgent : NSObject
-(void) unlockOrientation;
-(void) lockOrientation;
-(BOOL) isOrientationLocked;
@end

@interface SBLockScreenManager : NSObject
-(void) Rotate_AV;
@end

@interface AVPlayerViewController : UIViewController
@end

@interface AVLayoutView : UIView
@property NSString *debugIdentifier;
@end

@interface AVTouchIgnoringView : UIView
@end
 
 
 
CPDistributedMessagingCenter *_messagingCenter;
BOOL DidStartServer = NO;
BOOL DidInitButton = NO;



%hook AVPlayerViewController
-(void) viewWillAppear:(BOOL)arg {
  %orig;

  DidInitButton = NO;
}
%end 


 
#define MainPlist @"/var/mobile/Library/Application Support/RotateAV.plist"

void WriteToPlist(BOOL isLock) {

  NSMutableDictionary *MainDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:MainPlist];
  isLock ? [MainDictionary setValue:@"1" forKey:@"isLock"] : [MainDictionary setValue:@"2"forKey:@"isLock"];
  [MainDictionary writeToFile:MainPlist atomically:YES];
}

BOOL isLocked(void) {
  if ([[NSMutableDictionary dictionaryWithContentsOfFile:MainPlist][@"isLock"] isEqual:@"1"]) return YES;
  return NO;
}

 
%hook SBLockScreenManager 
-(void) lockScreenViewControllerDidDismiss {

  %orig;

  if (![[NSFileManager defaultManager] fileExistsAtPath:MainPlist]) 
  [@{} writeToFile:MainPlist atomically:YES];

  if (!DidStartServer) {
  _messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.crazymind90.RotationAV"];
  rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
  [_messagingCenter runServerOnCurrentThread];
  [_messagingCenter registerForMessageName:@"RotationAV" target:self selector:@selector(Rotate_AV)];
  DidStartServer = YES;
  }

  WriteToPlist([[%c(SBControlCenterSystemAgent) alloc] isOrientationLocked]);
}

%new
-(void) Rotate_AV {
    SBControlCenterSystemAgent *SystemAgent = [[%c(SBControlCenterSystemAgent) alloc] init];
 
    if ([SystemAgent isOrientationLocked])
    [SystemAgent unlockOrientation];
    else
    [SystemAgent lockOrientation];
}
%end

%hook SBControlCenterSystemAgent
-(void) unlockOrientation {
  %orig;
  WriteToPlist(NO);
}
-(void) lockOrientation {
  %orig;
  WriteToPlist(YES);
}
%end



%hook AVTouchIgnoringView 
-(void) layoutSubviews {
 
 %orig;

 if (self.subviews.count <= 0)
 return %orig;

 AVLayoutView *Layout = self.subviews[0];

 if ([Layout isKindOfClass:[%c(AVLayoutView) class]] && [Layout.debugIdentifier isEqual:@"ScreenModeControls"]) {

  if (!DidInitButton) { 
  UIButton *RotateButton = InitButtonWithName(@"",self,self,@selector(Button_Tapped:));
  
  if (isLocked()) { 
  [RotateButton setImage:[UIImage systemImageNamed:@"lock.rotation"] forState:UIControlStateNormal];
  RotateButton.tintColor = UIColor.orangeColor;
  RotateButton.tag = 1;
  } else { 
  [RotateButton setImage:[UIImage systemImageNamed:@"lock.rotation.open"] forState:UIControlStateNormal];
  RotateButton.tintColor = UIColorFromHEX(0x999999);
  RotateButton.tag = 2;
  }

  RotateButton.layer.cornerRadius = 16;
  RotateButton.layer.backgroundColor = UIColorFromHEX(0x212121).CGColor;

  [RotateButton setTranslatesAutoresizingMaskIntoConstraints:false];

  [NSLayoutConstraint activateConstraints:@[
  [RotateButton.topAnchor constraintEqualToAnchor:Layout.bottomAnchor constant:2],
  [RotateButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
  [RotateButton.trailingAnchor constraintEqualToAnchor:self.leadingAnchor constant:60],
  [RotateButton.bottomAnchor constraintEqualToAnchor:Layout.bottomAnchor constant:49]
  ]];

  DidInitButton = YES;
   }

 }

}

%new
-(void) Button_Tapped:(UIButton *)Sender {
    
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.crazymind90.RotationAV"];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    [c sendMessageName:@"RotationAV" userInfo:@{}];

    if (Sender.tag == 1) {
    [Sender setImage:[UIImage systemImageNamed:@"lock.rotation.open"] forState:UIControlStateNormal];
    Sender.tintColor = UIColorFromHEX(0x999999);
    Sender.tag = 2;
    } else {
    [Sender setImage:[UIImage systemImageNamed:@"lock.rotation"] forState:UIControlStateNormal];
    Sender.tintColor = UIColor.orangeColor;
    Sender.tag = 1;
    }
}

%end
 


 



// 