#import "SimplePaymentsPlugin.h"
#import <simple_payments/simple_payments-Swift.h>

@implementation SimplePaymentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSimplePaymentsPlugin registerWithRegistrar:registrar];
}
@end
