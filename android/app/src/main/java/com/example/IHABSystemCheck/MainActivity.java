package com.example.IHABSystemCheck;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.FileDescriptor;
import java.io.PrintWriter;

public class MainActivity extends AppCompatActivity {

    private final static String LOG = "SystemCheck";
    private static boolean isRecording;
    private static boolean isFinished;
    private static InputProfile_RFCOMM mInputProfile_RFCOMM = null;
    private Vibration mVibration = null;
    private TextView mInfoText = null;
    private ImageView mSymbol = null;
    private final static int MY_PERMISSIONS_READ_EXTERNAL_STORAGE = 0;
    private final static int MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE = 1;
    private final static int MY_PERMISSIONS_RECEIVE_BOOT_COMPLETED = 2;
    private final static int MY_PERMISSIONS_RECORD_AUDIO = 3;
    private final static int MY_PERMISSIONS_VIBRATE = 4;
    private final static int MY_PERMISSIONS_WAKE_LOCK = 5;
    private final static int MY_PERMISSIONS_DISABLE_KEYGUARD = 6;
    final Messenger mActivityMessenger = new Messenger(new MessageHandler());
    private final static int MSG_START_RECORDING = 1;
    private final static int MSG_STOP_RECORDING = 2;
    private final static int MSG_CHECK_FINISHED = 3;
    private static String messageDump = "";
    private static Handler mTaskHandler = new Handler();
    private int checkInterval = 100;

    BroadcastReceiver mCommandReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            try {
                String data = intent.getStringExtra("do");

                Log.e(LOG, "DATA: " + data);

                switch (data) {
                    case "Start":
                        mInputProfile_RFCOMM = new InputProfile_RFCOMM(MainActivity.this, mActivityMessenger);
                        mInputProfile_RFCOMM.registerClient();
                        mInputProfile_RFCOMM.setInterface();
                        break;
                    case "Stop":
                        mInputProfile_RFCOMM.cleanUp();
                        setIsRecording(false);
                        break;
                    case "Finished":
                        setIsFinished(true);
                        break;
                    case "Reset":
                        reset();
                        break;
                }

            } catch (Exception e) {
                Log.e(LOG, "Problem: " + e.toString());
            }
        }
    };

    private Runnable mSetTextRunnable = new Runnable() {
        @Override
        public void run() {
            if (getIsRecording() && !getIsFinished()) {
                mSymbol.setImageResource(R.drawable.mic);
                setMessageDump("Measuring");
            } else if (!getIsRecording() && !getIsFinished()) {
                mSymbol.setImageResource(R.drawable.hourglass);
                setMessageDump("Waiting");
            } else {
                mSymbol.setImageResource(R.drawable.check);
                setMessageDump("Finished");
            }
            mTaskHandler.postDelayed(mSetTextRunnable, checkInterval);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        registerReceiver(mCommandReceiver, new IntentFilter("command"));

        mSymbol = findViewById(R.id.symbol);

        requestPermissions(MY_PERMISSIONS_RECORD_AUDIO);

        // Create home directory
        String path = AudioFileIO.getMainFolderPath();

        Log.e(LOG, "New path: " + path);

        mTaskHandler.post(mSetTextRunnable);

    }

    @Override
    protected void onDestroy() {
        setIsFinished(false);
        setIsRecording(false);
        mTaskHandler.removeCallbacks(mSetTextRunnable);
        mInputProfile_RFCOMM = null;
        unregisterReceiver(mCommandReceiver);
        super.onDestroy();
    }

    @Override
    public void dump(String prefix, FileDescriptor fd, PrintWriter writer, String[] args) {
        writer.println(getMessageDump());
    }

    public static void setMessageDump(String message) {
        messageDump = message;
    }

    public static String getMessageDump() {
        return messageDump;
    }

    public static void setIsFinished(boolean finished) {
        isFinished = finished;
    }

    public static boolean getIsFinished() {
        return isFinished;
    }

    public void reset() {

        finishAffinity();
        Intent intent = new Intent(getApplicationContext(), MainActivity.class);
        startActivity(intent);
    }

    public static void setIsRecording(boolean recording) {
        isRecording = recording;
    }

    public static boolean getIsRecording() {
        return isRecording;
    }

    public void requestPermissions(int iPermission) {

        // TODO: Make array
        switch (iPermission) {
            case 0:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                        MY_PERMISSIONS_READ_EXTERNAL_STORAGE);
                break;
            case 1:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                        MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE);
                break;
            case 2:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.RECEIVE_BOOT_COMPLETED},
                        MY_PERMISSIONS_RECEIVE_BOOT_COMPLETED);
                break;
            case 3:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.RECORD_AUDIO},
                        MY_PERMISSIONS_RECORD_AUDIO);
                break;
            case 4:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.VIBRATE},
                        MY_PERMISSIONS_VIBRATE);
                break;
            case 5:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.WAKE_LOCK},
                        MY_PERMISSIONS_WAKE_LOCK);
                break;
            case 6:
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.DISABLE_KEYGUARD},
                        MY_PERMISSIONS_DISABLE_KEYGUARD);
                break;

        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {

        switch (requestCode) {

            case MY_PERMISSIONS_RECORD_AUDIO: {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                    requestPermissions(MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE);
                } else {
                    requestPermissions(MY_PERMISSIONS_RECORD_AUDIO);
                }
                break;
            }
            case MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE: {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    requestPermissions(MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE);
                } else if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                    requestPermissions(MY_PERMISSIONS_RECORD_AUDIO);
                }
                break;
            }
        }
    }

    class MessageHandler extends Handler {

        @Override
        public void handleMessage(Message msg) {

            Log.d(LOG, "Received Message: " + msg.what);

            switch (msg.what) {

                default:
                    super.handleMessage(msg);
                    break;
            }
        }
    }

}
