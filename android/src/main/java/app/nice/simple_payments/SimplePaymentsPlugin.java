package app.nice.simple_payments;

import android.content.Intent;
import java.io.Serializable;
import java.util.Map;
import app.nice.simple_payments.PayStripe;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SimplePaymentsPlugin */
public class SimplePaymentsPlugin {

  public static Result result;

  /** Plugin registration. */
  public static void registerWith(final Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_payments");

    channel.setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("payWithStripe")) {
          Map<String, Object> map = (Map<String, Object>) call.arguments;
          Intent i = new Intent(registrar.context(), PayStripe.class);
          i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          i.putExtra("map", (Serializable) map);
          SimplePaymentsPlugin.result = result;
          registrar.activity().startActivity(i);
        } else {
          result.notImplemented();
        }
      }
    });
  }

}
