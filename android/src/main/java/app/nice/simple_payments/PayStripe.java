package app.nice.simple_payments;

import android.app.ProgressDialog;
import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.stripe.android.Stripe;
import com.stripe.android.TokenCallback;
import com.stripe.android.model.Card;
import com.stripe.android.model.Token;
import com.stripe.android.view.CardInputWidget;

import java.util.HashMap;

import cz.msebera.android.httpclient.Header;

public class PayStripe extends AppCompatActivity {

    private HashMap<String, Object> map;
    private CardInputWidget mCardInputWidget;
    private ProgressDialog progressDialog;
    private Button btn_pay;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pay_stripe);

        if (getIntent().getSerializableExtra("map") != null) {
            map = (HashMap<String, Object>) getIntent().getSerializableExtra("map");
            mCardInputWidget = findViewById(R.id.card_input_widget);
            btn_pay = findViewById(R.id.btn_pay);
            btn_pay.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    pay();
                }
            });
        } else {
            endTask("Finish");
        }
    }

    public void endTask(String msg) {
        if (this.progressDialog != null) {
            progressDialog.dismiss();
        }
        if (SimplePaymentsPlugin.result != null) {
            SimplePaymentsPlugin.result.success(msg);
            finish();
        }
    }

    private void pay() {
        this.btn_pay.setEnabled(false);
        progressDialog = dialogProgress(this,"Starting payment...", "Pay", false);
        progressDialog.show();
        Card card = mCardInputWidget.getCard();
        if (card != null && map.get("body") != null && map.get("stripePub") != null) {

            Stripe stripe = new Stripe(this, (String) map.get("stripePub"));
            stripe.createToken(
                    card,
                    new TokenCallback() {
                        public void onSuccess(Token token) {
                            // Send token to your server

                            AsyncHttpClient client = new AsyncHttpClient();
                            client.setTimeout(35000);
                            client.setConnectTimeout(35000);
                            client.setResponseTimeout(35000);
                            // client.addHeader("application/json", "Content-Type");
                            // client.addHeader("application/json", "Accept");
                            RequestParams params = new RequestParams();
                            params.put("tokenStripe", token.getId());
                            HashMap<String, Object> mapBody = (HashMap<String, Object>) map.get("body");
                            Object[] keys = mapBody.keySet().toArray();
                            for (Object key : keys) {
                                params.put((String) key, mapBody.get(key));
                            }
                            client.post((String) map.get("url"), params,
                                    new AsyncHttpResponseHandler() {
                                        @Override
                                        public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                                            endTask(new String(responseBody));
                                        }

                                        @Override
                                        public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                                            endTask("Error: " + error.getMessage());
                                        }
                                    }
                            );
                        }
                        public void onError(Exception error) {
                            // Show localized error message
                            error.printStackTrace();
                            endTask("Error: " + error.getMessage());
                        }
                    }
            );
        } else {
            endTask("Error: Some of the data not correct, check URL again, Stripe Publisher Key and the amount must be higher then 0.5 dolars");
        }

    }

    public ProgressDialog dialogProgress(Context context, String msg, String title, boolean cancel) {
        ProgressDialog dialog = new ProgressDialog(context);
        dialog.setMessage(msg);
        if (title != null) {
            dialog.setTitle(title);
        }

        dialog.setCancelable(cancel);

        return dialog;
    }

}
