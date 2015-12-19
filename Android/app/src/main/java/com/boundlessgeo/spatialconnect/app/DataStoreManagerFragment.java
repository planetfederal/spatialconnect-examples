package com.boundlessgeo.spatialconnect.app;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;

import java.util.List;

/**
 * The DataStoreManagerFragment displays a list of active SCDataStore instances that the user can choose from to
 * interact with.
 */
public class DataStoreManagerFragment extends Fragment implements ListView.OnItemClickListener {

    private ListView listView;
    private OnDataStoreSelectedListener dataStoreSelectedListener;
    private FragmentManager fragmentManager;

    /** entry point into spatial connect...TODO: the fragment needs it to be an instance variable?? **/
    protected SCServiceManager serviceManager;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        // inflate the views
        View view = inflater.inflate(R.layout.fragment_manager, null);
        listView = (ListView) view.findViewById(R.id.fragment_manager_list);
        fragmentManager = getFragmentManager();

        // Set the list's click listener
        listView.setOnItemClickListener(this);

        return view;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // initialize servicemanage
        serviceManager =  SpatialConnectService.getInstance().getServiceManager(getContext());
        new StartAllServicesTask().execute();
        serviceManager.startAllServices();
        serviceManager.getDataService().allStoresStartedObs();
    }

    public void onDataStoreSelected(SCDataStore dataStore) {
        Intent intent = new Intent(getActivity(),DataStoreDetailsActivity.class);
        intent.putExtra("id",dataStore.getStoreId());
        startActivity(intent);
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        // TODO Auto-generated method stub
        super.onHiddenChanged(hidden);
        if (hidden) {
            //fragment became visible
            //your code here
        }
    }

    /**
     *  Starts all the services in a background thread b/c it needs to perform network or file i/o.  Once they have
     *  started, it populates the listView with the active data stores.
     */
    private class StartAllServicesTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... params) {
            serviceManager.startAllServices();
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            // show toast indicating number of active data stores
            Toast.makeText(
                    getActivity(),
                    serviceManager.getDataService().getActiveStores().size() + " data stores have been activated.",
                    Toast.LENGTH_SHORT
            ).show();

            // Set the adapter for the list view
            List<SCDataStore> s = serviceManager.getDataService().getActiveStores();
            listView.setAdapter(
                    new ArrayAdapter<SCDataStore>(
                            getActivity(),
                            R.layout.drawer_list_item,
                            s
                    )
            );
        }
    }

    /**
     * The MainActivity must implement this so it can update its selectedStore and notify the map.
     *
     * @see <a href="http://developer.android.com/guide/components/fragments.html#EventCallbacks">
     *     http://developer.android.com/guide/components/fragments.html#EventCallbacks<</a>
     */
    public interface OnDataStoreSelectedListener {
        public void onDataStoreSelected(SCDataStore dataStore);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            dataStoreSelectedListener = (OnDataStoreSelectedListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnDataStoreSelectedListener");
        }
    }

    @Override
    public void onItemClick(AdapterView parent, View view, int position, long id) {
        listView.setItemChecked(position, true);
        SCDataStore s = (SCDataStore)listView.getItemAtPosition(position);
        this.onDataStoreSelected(s);
    }

}


