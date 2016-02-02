package com.boundlessgeo.spatialconnect.app;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.boundlessgeo.spatialconnect.geometries.SCGeometry;
import com.boundlessgeo.spatialconnect.geometries.SCSpatialFeature;
import com.boundlessgeo.spatialconnect.jsbridge.SCJavascriptBridgeHandler;
import com.boundlessgeo.spatialconnect.jsbridge.WebBundleUtil;
import com.boundlessgeo.spatialconnect.jsbridge.WebViewJavascriptBridge;
import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;
import com.boundlessgeo.spatialconnect.stores.SCDataStoreStatus;
import com.google.android.gms.maps.model.LatLng;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.PrecisionModel;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import rx.functions.Action1;


/**
 * The MainActivity is the home screen that contains the MapsFragment, and DataStoreFragment.  It is the main entry
 * point into this example application.
 */
public class MainActivity extends Activity implements
        NavigationDrawerFragment.NavigationDrawerCallbacks,
        WebBundleManagerFragment.OnWebBundleSelectedListener {

    private static final String TAG = MainActivity.class.getSimpleName();

    /**
     * Manager drawer position
     */
    private static final int DATA_STORE_MANAGER_POSITION = 0;

    /**
     * Web bundle drawer position
     */
    private static final int WEB_BUNDLE_MANAGER_POSITION = 1;

    /**
     * Map drawer position
     */
    private static final int MAP_POSITION = 2;

    /**
     * Current drawer position, defaults to data store manager
     */
    private int navigationPosition = MAP_POSITION;


    private MapsFragment mapsFragment;
    private DataStoreManagerFragment dataStoreManagerFragment;
    private WebBundleManagerFragment webBundleManagerFragment;

    private SCServiceManager manager;
    private SCDataStore selectedStore;
    private File selectedWebBundle;
    private static final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);


    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment navigationDrawerFragment;

    /**
     * Used to store the last screen title.
     */
    private CharSequence title;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        title = getString(R.string.app_name);

        // get the fragments
        mapsFragment = new MapsFragment();
        dataStoreManagerFragment = new DataStoreManagerFragment();
        webBundleManagerFragment = new WebBundleManagerFragment();
        navigationDrawerFragment =
                (NavigationDrawerFragment) getFragmentManager().findFragmentById(R.id.navigation_drawer);

        // Set up the drawer.
        navigationDrawerFragment.setUp(R.id.navigation_drawer, (DrawerLayout) findViewById(R.id.drawer_layout));

        // insert the starting fragment into the container
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.add(R.id.container, dataStoreManagerFragment);
        transaction.commit();

        // setup service manager
        manager = SpatialConnectService.getInstance().getServiceManager(this, getConfigFile());
    }

    private File getConfigFile() {
        File file = null;
        try {
            file = File.createTempFile("config.scfg", null, this.getCacheDir());
            InputStream is = this.getResources().openRawResource(R.raw.config);
            FileOutputStream fos = new FileOutputStream(file);
            byte[] data = new byte[is.available()];
            is.read(data);
            fos.write(data);
            is.close();
            fos.close();
        } catch (IOException ex) {
            Log.e(TAG, "Could not successfully initialize SpatialConnect configuration.", ex);
            System.exit(0);
        }
        return file;
    }


    @Override
    public void onNavigationDrawerItemSelected(int position) {
        // hide web view if it was opened
        WebView webView = (WebView) findViewById(R.id.webview);
        if (webView != null) {
            webView.setVisibility(View.GONE);
        }

        // update the main content by replacing fragments
        FragmentManager fragmentManager = getFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();

        switch (position) {

            case DATA_STORE_MANAGER_POSITION:
                if (dataStoreManagerFragment != null) {
                    transaction.remove(mapsFragment);
                    transaction.remove(webBundleManagerFragment);
                    transaction.replace(R.id.container, dataStoreManagerFragment);
                    title = getString(R.string.title_data_store_manager);
                }
                break;
            case WEB_BUNDLE_MANAGER_POSITION:
                transaction.remove(mapsFragment);
                transaction.remove(dataStoreManagerFragment);
                if (webBundleManagerFragment != null) {
                    transaction.replace(R.id.container, webBundleManagerFragment);
                    transaction.show(webBundleManagerFragment);
                    title = getString(R.string.title_web_bundle_manager);
                }
                break;
            case MAP_POSITION:
                transaction.remove(webBundleManagerFragment);
                transaction.remove(dataStoreManagerFragment);
                if (mapsFragment != null) {
                    transaction.replace(R.id.container, mapsFragment);
                    title = getString(R.string.title_map);
                }
                break;
            default:

        }

        navigationPosition = position;

        transaction.commit();
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }
        if (id == R.id.action_reload_features) {
            mapsFragment.reloadFeatures();
            return true;
        }
        if (id == R.id.action_load_imagery) {
            mapsFragment.loadImagery();
            return true;
        }
        if (id == R.id.action_add_feature) {
            if (manager.getDataService().getStoreById("a5d93796-5026-46f7-a2ff-e5dec85heh6b").getStatus()
                    .equals(SCDataStoreStatus.SC_DATA_STORE_RUNNING)) {
                LatLng center = mapsFragment.map.getCameraPosition().target;
                SCSpatialFeature newFeature = new SCGeometry(
                        geometryFactory.createPoint(new Coordinate(center.longitude, center.latitude))
                );
                newFeature.setStoreId("a5d93796-5026-46f7-a2ff-e5dec85heh6b");
                newFeature.setLayerId("point_features");
                manager.getDataService()
                        .getStoreById(newFeature.getKey().getStoreId())
                        .create(newFeature)
                        .subscribe(new Action1<SCSpatialFeature>() {
                            @Override
                            public void call(SCSpatialFeature feature) {
                                mapsFragment.addMarkerToMap(feature);
                            }
                        });
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public SCDataStore getSelectedStore() {
        return selectedStore;
    }

    /**
     * Handle the selected web bundle file and switch to WebView.
     *
     * @param file - the directory containing the bundle
     */
    @Override
    public void onWebBundleSelectedListener(File file) {
        selectedWebBundle = file;
        onNavigationDrawerItemSelected(WEB_BUNDLE_MANAGER_POSITION);
        WebView webView = (WebView) findViewById(R.id.webview);
        WebSettings settings = webView.getSettings();
        settings.setDomStorageEnabled(true);
        settings.setJavaScriptEnabled(true);
        // setup js bridge in webview
        SCJavascriptBridgeHandler handler = new SCJavascriptBridgeHandler(manager);
        final WebViewJavascriptBridge bridge = new WebViewJavascriptBridge(this, webView, handler);
        File indexFile = new WebBundleUtil(this).getIndexFromBundle(file);
        webView.loadUrl(Uri.fromFile(indexFile).toString());
        webView.setVisibility(View.VISIBLE);
        getFragmentManager().beginTransaction().hide(webBundleManagerFragment).commit();
    }


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        WebView webView = (WebView) findViewById(R.id.webview);
        // Check if the key event was the Back button and if there's history
        if ((keyCode == KeyEvent.KEYCODE_BACK) && webView.canGoBack()) {
            webView.goBack();
            return true;
        }
        // If it wasn't the Back key or there's no web page history, bubble up to the default
        // system behavior (probably exit the activity)
        return super.onKeyDown(keyCode, event);
    }
}
