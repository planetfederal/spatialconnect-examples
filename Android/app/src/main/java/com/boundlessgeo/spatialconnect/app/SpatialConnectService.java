package com.boundlessgeo.spatialconnect.app;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;

import com.boundlessgeo.spatialconnect.services.SCServiceManager;

public class SpatialConnectService extends Service {
    private static SpatialConnectService singleton = new SpatialConnectService();
    SCServiceManager manager;

    public static SpatialConnectService getInstance() {
        return singleton;
    }

    public SCServiceManager getServiceManager(Context c) {
        if (manager == null) {
            manager = new SCServiceManager(c);
        }
        return manager;
    }

    @Override
    public IBinder onBind(Intent i) {
        return null;
    }
}
