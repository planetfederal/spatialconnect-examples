package com.boundlessgeo.spatialconnect.app;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;

import com.boundlessgeo.spatialconnect.services.SCServiceManager;

import java.io.File;

public class SpatialConnectService extends Service {
    private static SpatialConnectService singleton = new SpatialConnectService();
    SCServiceManager manager;

    public static SpatialConnectService getInstance() {
        return singleton;
    }

    public SCServiceManager getServiceManager(Context c, File... configFiles) {
        if (manager == null) {
            manager = new SCServiceManager(c, configFiles);
        }
        return manager;
    }

    @Override
    public IBinder onBind(Intent i) {
        return null;
    }
}
