package io.inway.ringtone.player;

import android.content.Context;
import android.media.AudioManager;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterRingtonePlayerPlugin
 */
public class FlutterRingtonePlayerPlugin implements MethodCallHandler, RingtoneLoaderTask.LoadCompleteListener {
    private final Context context;
    private final RingtoneManager ringtoneManager;
    private Ringtone ringtone;
    private RingtoneLoaderTask mLoaderTask;
    private Result loadRingtoneResult;

    public FlutterRingtonePlayerPlugin(Context context) {
        this.context = context;
        this.ringtoneManager = new RingtoneManager(context);
        this.ringtoneManager.setStopPreviousRingtone(true);
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_ringtone_player");
        channel.setMethodCallHandler(new FlutterRingtonePlayerPlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        try {
            Uri ringtoneUri = null;

            if (call.method.equals("play") && !call.hasArgument("android")) {
                result.notImplemented();
            } else if (call.method.equals("play")) {
                final int kind = call.argument("android");

                switch (kind) {
                    case 1:
                        ringtoneUri = Settings.System.DEFAULT_ALARM_ALERT_URI;
                        break;
                    case 2:
                        ringtoneUri = Settings.System.DEFAULT_NOTIFICATION_URI;
                        break;
                    case 3:
                        ringtoneUri = Settings.System.DEFAULT_RINGTONE_URI;
                        break;
                    default:
                        result.notImplemented();
                }
            } else if (call.method.equals("stop")) {
                if (ringtone != null) {
                    ringtone.stop();
                }

                result.success(null);
            } else if (call.method.equals("loadRingtone")) {
                loadRingtoneResult = result;
                if (null != mLoaderTask) {
                    mLoaderTask.cancel(true);
                    mLoaderTask = null;
                }
                mLoaderTask = new RingtoneLoaderTask(context, this);
                //noinspection unchecked
                ArrayList list = new ArrayList();
                list.add(RingtonePickerDialog.Builder.TYPE_RINGTONE);
                mLoaderTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, list);
                return;
            } else if (call.method.equals("playSystemRingtone")) {
                final String ringtonePath = call.argument("ringtonePath");
                ringtoneUri = Uri.parse(ringtonePath);
                if (ringtone != null) {
                    ringtone.stop();
                }
                ringtone = ringtoneManager.getRingtone(context, ringtoneUri);
                ringtone.play();
                result.success(null);
                return;
            }

            if (ringtoneUri != null) {
                if (ringtone != null) {
                    ringtone.stop();
                }
                ringtone = ringtoneManager.getRingtone(context, ringtoneUri);

                if (call.hasArgument("volume")) {
                    final double volume = call.argument("volume");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        ringtone.setVolume((float) volume);
                    }
                }

                if (call.hasArgument("looping")) {
                    final boolean looping = call.argument("looping");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        ringtone.setLooping(looping);
                    }
                }

                if (call.hasArgument("asAlarm")) {
                    final boolean asAlarm = call.argument("asAlarm");
                    /* There's also a .setAudioAttributes method
                       that is more flexible, but .setStreamType
                       is supported in all Android versions
                       whereas .setAudioAttributes needs SDK > 21.
                       More on that at
                       https://developer.android.com/reference/android/media/Ringtone
                    */
                    if (asAlarm) {
                        ringtone.setStreamType(AudioManager.STREAM_ALARM);
                    }
                }

                ringtone.play();

                result.success(null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.error("Exception", e.getMessage(), null);
        }
    }

    @Override
    public void onLoadComplete(@NonNull HashMap<String, Uri> ringtone) {
        final HashMap<String, String> ringtoneMap = new HashMap();
        for (String key : ringtone.keySet()) {
            ringtoneMap.put(key, ringtone.get(key).toString());
        }
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != loadRingtoneResult) {
                    loadRingtoneResult.success(ringtoneMap);
                    loadRingtoneResult = null;
                }
            }
        });

    }
}
