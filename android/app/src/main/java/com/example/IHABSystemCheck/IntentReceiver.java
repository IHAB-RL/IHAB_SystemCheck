package com.example.IHABSystemCheck;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

public class IntentReceiver extends BroadcastReceiver {

    final String tag = "Intent Intercepter";

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            String data = intent.getStringExtra("sms_body");
            Log.e(tag, data);

            switch (data) {
                case "Start":
                    MainActivity.startRecording();
                    break;

                case "Stop":
                    MainActivity.stopRecording();
                    break;

                case "Finished":
                    MainActivity.setIsFinished(true);
                    break;

                case "Reset":
                    MainActivity.reset();
                    break;
            }
        } catch (Exception e) {
        }
    }
}