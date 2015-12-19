package com.boundlessgeo.spatialconnect.app;

import android.app.ActionBar;
import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;

import java.io.File;

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

        // TODO: handle menu click events in each Fragment
        if (id == R.id.action_settings) {
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
        webView.setWebViewClient(new WebViewClient());
        webView.loadUrl(Uri.fromFile(selectedWebBundle).toString() + "/index.html");
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
