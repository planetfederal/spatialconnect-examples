package com.boundlessgeo.spatialconnect.app;

import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.os.Environment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * Web bundles are stored in external storage.
 */
public class WebBundleManagerFragment extends Fragment implements ListView.OnItemClickListener {

    private ListView listView;
    private OnWebBundleSelectedListener webBundleSelectedListener;
    private static final String BUNDLE_DIRECTORY_NAME = "bundles";

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // inflate the views
        View view = inflater.inflate(R.layout.fragment_manager, null);
        listView = (ListView) view.findViewById(R.id.fragment_manager_list);

        // Set the adapter for the list view
        listView.setAdapter(new WebBundleAdapter(getActivity(), R.layout.item_web_bundle, getWebBundleFiles()));

        // Set the list's click listener
        listView.setOnItemClickListener(this);

        return view;
    }

    // TODO: ensure that new bundles that are added are shown the next time "Web Bundles" navigation item is clicked

    /**
     * The MainActivity must implement this so it can update its selectedWebBundle and notify the WebView launcher.
     *
     * @see <a href="http://developer.android.com/guide/components/fragments.html#EventCallbacks">
     * http://developer.android.com/guide/components/fragments.html#EventCallbacks<</a>
     */
    public interface OnWebBundleSelectedListener {
        void onWebBundleSelectedListener(File file);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            webBundleSelectedListener = (OnWebBundleSelectedListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnWebBundleSelectedListener");
        }
    }


    /**
     * When an item in the listView is clicked, this callback is called.
     *
     * @param parent
     * @param view
     * @param position
     * @param id
     */
    @Override
    public void onItemClick(AdapterView parent, View view, int position, long id) {
        listView.setItemChecked(position, true);
        webBundleSelectedListener.onWebBundleSelectedListener((File) listView.getItemAtPosition(position));
    }

    /**
     * Helper method to unzip any zip files in the bundle directory and return a array of File objects for the
     * unzipped web bundle directories.
     */
    private File[] getWebBundleFiles() {
        ArrayList<File> bundleList = new ArrayList<>();

        File folder = new File(Environment.getExternalStorageDirectory() + "/" + BUNDLE_DIRECTORY_NAME);
        if (!folder.exists()) {
            folder.mkdir();
        }
        File bundlesDir = getActivity().getExternalFilesDir(BUNDLE_DIRECTORY_NAME);

        // if the zip file isn't already unzipped in the bundles directory, then unzip it
        for (File f : bundlesDir.listFiles()) {
            if (f.isFile() && !bundleIsUnzipped(f)) {
                ZipFile zipFile = null;
                try {
                    zipFile = new ZipFile(f);
                    Enumeration<? extends ZipEntry> entries = zipFile.entries();
                    while (entries.hasMoreElements()) {
                        ZipEntry entry = entries.nextElement();
                        File entryDestination = new File(bundlesDir, entry.getName());
                        if (entry.isDirectory())
                            entryDestination.mkdirs();
                        else {
                            entryDestination.getParentFile().mkdirs();
                            InputStream in = zipFile.getInputStream(entry);
                            OutputStream out = new FileOutputStream(entryDestination);
                            IOUtils.copy(in, out);
                            IOUtils.closeQuietly(in);
                            out.close();
                        }
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        zipFile.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        // add all unzipped bundles
        for (File f : bundlesDir.listFiles()) {
            if (f.isDirectory() && !f.getName().equals("__MACOSX")) {
                bundleList.add(f);
            }
        }

        return bundleList.toArray(new File[bundleList.size()]);
    }

    /**
     * Helper method to determine if a web bundle has been unzipped in the bundles directory.
     *
     * @param bundle - a file that may or may not have been unziped
     * @return true if a directory with the bundle name exists in the bundles directory
     */
    private boolean bundleIsUnzipped(File bundle) {
        String bundleName = bundle.getName().replace(".zip", "");
        File bundlesDir = getActivity().getExternalFilesDir(BUNDLE_DIRECTORY_NAME);
        return new File(bundlesDir, bundleName).exists();
    }

    /**
     * Custom adapter to show the File name of the web bundle.
     */
    class WebBundleAdapter extends ArrayAdapter<File> {

        public WebBundleAdapter(Context context, int resource, File[] files) {
            super(context, resource, files);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            File file = getItem(position);
            LayoutInflater inflater = LayoutInflater.from(getActivity());
            View rowView = inflater.inflate(R.layout.item_web_bundle, parent, false);
            TextView textView = (TextView) rowView.findViewById(R.id.web_bundle_name);
            textView.setText(file.getName());
            return rowView;
        }
    }

}
