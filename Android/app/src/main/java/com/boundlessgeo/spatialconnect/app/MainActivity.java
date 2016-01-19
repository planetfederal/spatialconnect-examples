package com.boundlessgeo.spatialconnect.app;

import android.app.ActionBar;
import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.boundlessgeo.spatialconnect.jsbridge.BridgeCommand;
import com.boundlessgeo.spatialconnect.jsbridge.WebViewJavascriptBridge;
import com.boundlessgeo.spatialconnect.services.SCSensorService;
import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import java.io.File;
import java.io.IOException;
import java.util.List;

import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;
import rx.schedulers.Schedulers;

/**
 * The MainActivity is the home screen that contains the MapsFragment, and DataStoreFragment.  It is the main entry
 * point into this example application.
 */
public class MainActivity extends Activity implements
        NavigationDrawerFragment.NavigationDrawerCallbacks,
        DataStoreManagerFragment.OnDataStoreSelectedListener,
        WebBundleManagerFragment.OnWebBundleSelectedListener {

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


    //private MapFragment mapFragment;
    private MapsFragment mapsFragment;
    private DataStoreManagerFragment dataStoreManagerFragment;
    private WebBundleManagerFragment webBundleManagerFragment;

    private SCServiceManager manager;
    private SCDataStore selectedStore;
    private File selectedWebBundle;
    private WebViewJavascriptBridge bridge;
    private static final ObjectMapper MAPPER = new ObjectMapper();

    static {
        MAPPER.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
    }

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment navigationDrawerFragment;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
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
        manager = SpatialConnectService.getInstance().getServiceManager(getApplicationContext());
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
                    transaction.replace(R.id.container, dataStoreManagerFragment);
                    title = getString(R.string.title_data_store_manager);
                }
                break;
            case WEB_BUNDLE_MANAGER_POSITION:
                if (webBundleManagerFragment != null) {
                    transaction.replace(R.id.container, webBundleManagerFragment);
                    transaction.show(webBundleManagerFragment);
                    title = getString(R.string.title_web_bundle_manager);
                }
                break;
            case MAP_POSITION:
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
    public boolean onCreateOptionsMenu(Menu menu) {

        if (!navigationDrawerFragment.isDrawerOpen()) {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.main, menu);
            restoreActionBar();
            return true;
        }
        return super.onCreateOptionsMenu(menu);
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
            startActivity(new Intent(this, AddNewFeatureActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    /**
     * Helper method to restore the ActionBar to the previous state
     */
    public void restoreActionBar() {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setTitle(title);
    }

    public SCDataStore getSelectedStore() {
        return selectedStore;
    }

    /**
     * Handle the selected data store and switch to map view.
     *
     * @param dataStore
     */
    @Override
    public void onDataStoreSelected(SCDataStore dataStore) {
        // update the selected data store
        selectedStore = dataStore;
        // switch to map view
        onNavigationDrawerItemSelected(MAP_POSITION);
    }

    /**
     * Handle the selected web bundle file and switch to WebView.
     *
     * @param file
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
        bridge = new WebViewJavascriptBridge(this, webView, new BridgeHandler());
        webView.loadUrl(Uri.fromFile(selectedWebBundle).toString() + "/index.html");
        webView.setVisibility(View.VISIBLE);
        getFragmentManager().beginTransaction().hide(webBundleManagerFragment).commit();
    }

    /**
     * Default implementation for handling messages from the JS bridge.
     */
    class BridgeHandler implements WebViewJavascriptBridge.WVJBHandler {

        private final String LOG_TAG = BridgeHandler.class.getSimpleName();

        @Override
        public void handle(String data, WebViewJavascriptBridge.WVJBResponseCallback jsCallback) {
            if (data == null && data.equals("undefined")) {
                Log.w(LOG_TAG, "data message was null or undefined");
                return;
            } else {
                JsonNode bridgeMessage = getBridgeMessage(data);
                Integer actionNumber = getActionNumber(bridgeMessage);
                BridgeCommand command = BridgeCommand.fromActionNumber(actionNumber);

                if (command.equals(BridgeCommand.SENSORSERVICE_GPS)) {
                    SCSensorService sensorService = manager.getSensorService();
                    Integer payloadNumber = getPayloadNumber(bridgeMessage);

                    if (payloadNumber == 1) {
                        sensorService.startGPSListener();
                        sensorService.getLastKnownLocation()
                                .subscribeOn(Schedulers.newThread())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe(new Action1<Location>() {
                                    @Override
                                    public void call(Location location) {
                                        bridge.callHandler("lastKnownLocation",
                                                "{\"  lat\":\"" + location.getLatitude() + "\"," +
                                                        "\"lon\":\"" + location.getLongitude() + "\"}");
                                    }
                                });
                        return;
                    }
                    if (payloadNumber == 0) {
                        sensorService.disableGPSListener();
                        return;
                    }
                }
                if (command.equals(BridgeCommand.DATASERVICE_ACTIVESTORESLIST)) {
                    List<SCDataStore> stores = manager.getDataService().getActiveStores();
                    StringBuilder sb = new StringBuilder();
                    for (SCDataStore store : stores) {
                        if (sb.length() != 0) {
                            sb.append(",");
                        }
                        sb.append("\"").append(store.toString()).append("\"");
                    }
                    bridge.callHandler("storesList", "{\"stores\": [" + sb.toString() + "]}");
                    return;
                }
                if (command.equals(BridgeCommand.DATASERVICE_ACTIVESTOREBYID)) {
                    String storeId = getStoreId(bridgeMessage);
                    String dataStoreString = null;
                    try {
                        dataStoreString = MAPPER.writeValueAsString(manager.getDataService().getStoreById(storeId));
                    } catch (JsonProcessingException e) {
                        e.printStackTrace();
                        return;
                    }
                    bridge.callHandler("store", dataStoreString);
                    return;
                }
            }
        }

        // gets either a 1 or a 0 indicating turn on/off something
        private Integer getPayloadNumber(JsonNode payload) {
            return payload.get("payload").asInt();
        }

        private String getStoreId(JsonNode payload) {
            return payload.get("payload").get("storeId").asText();
        }

        private Integer getActionNumber(JsonNode payload) {
            return payload.get("action").asInt();
        }

        private JsonNode getBridgeMessage(String payload) {
            try {
                return MAPPER.readTree(payload);
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

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
