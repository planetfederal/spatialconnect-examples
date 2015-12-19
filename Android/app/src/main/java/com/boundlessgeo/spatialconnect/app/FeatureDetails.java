package com.boundlessgeo.spatialconnect.app;

import android.os.Bundle;
import android.app.Activity;

public class FeatureDetails extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_feature_details);
        getActionBar().setDisplayHomeAsUpEnabled(true);
    }

}
