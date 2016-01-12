package com.boundlessgeo.spatialconnect.app;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import com.boundlessgeo.spatialconnect.geometries.SCBoundingBox;
import com.boundlessgeo.spatialconnect.geometries.SCGeometry;
import com.boundlessgeo.spatialconnect.query.SCGeometryPredicateComparison;
import com.boundlessgeo.spatialconnect.query.SCPredicate;
import com.boundlessgeo.spatialconnect.query.SCQueryFilter;
import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;

import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;
import rx.schedulers.Schedulers;

/**
 * A placeholder fragment containing a simple view.
 */
public class FeatureDetailsFragment extends Fragment implements OnMapReadyCallback {

    private String featureId,layerId,storeId;
    private double lat,lon;
    private TextView latVal, lonVal;
    private GoogleMap map;
    private MapView mapView;
    private SCGeometry selectedFeature;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        Bundle b = getActivity().getIntent().getExtras();
        lat = (double)b.get("lat");
        lon = (double)b.get("lon");
        this.featureId = (String)b.get("fid");
        this.layerId = (String)b.get("lid");
        this.storeId = (String)b.get("sid");

        View inflatedView = inflater.inflate(R.layout.fragment_feature_details, container, false);

        // Gets the MapView from the XML layout and creates it
        mapView = (MapView) inflatedView.findViewById(R.id.edit_point_map);
        mapView.onCreate(savedInstanceState);
        // Gets to GoogleMap from the MapView and does initialization stuff
        mapView.getMapAsync(this);

        return inflatedView;
    }

    @Override
    public void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mapView.onLowMemory();
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        SCServiceManager serviceManager =  SpatialConnectService.getInstance().getServiceManager(getContext());
        SCDataStore ds = serviceManager.getDataService().getStoreById(storeId);

        int auth = ds.getAuthorization();

        final TextView storeIdVal = (TextView)getView().findViewById(R.id.feature_detail_store_value);
        final TextView layerVal = (TextView)getView().findViewById(R.id.feature_detail_layer_value);
        lonVal = (TextView)getView().findViewById(R.id.feature_detail_lon_value);
        latVal = (TextView)getView().findViewById(R.id.feature_detail_lat_value);
        final TextView altVal = (TextView)getView().findViewById(R.id.feature_detail_alt_value);
        final TextView featIdVal = (TextView)getView().findViewById(R.id.feature_detail_featureid_value);
        final TableLayout table = (TableLayout)getView().findViewById(R.id.feature_detail_prop_table);

        SCBoundingBox bbox = new SCBoundingBox(lon,lat,lon,lat);
        SCPredicate p = new SCPredicate(bbox, SCGeometryPredicateComparison.SCPREDICATE_OPERATOR_WITHIN);
        SCQueryFilter filter = new SCQueryFilter(p);
        ds.query(filter)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .take(1)
                .subscribe(new Subscriber<SCGeometry>() {
                               @Override
                               public void onCompleted() {

                               }

                               @Override
                               public void onError(Throwable e) {

                               }

                               @Override
                               public void onNext(final SCGeometry s) {
                                   selectedFeature = s;
                                   storeIdVal.setText(s.getKey().getStoreId());
                                   layerVal.setText(s.getKey().getLayerId());
                                   if (s.getGeometry() instanceof Point) {
                                       Point pt = (Point) s.getGeometry();
                                       lonVal.setText(String.valueOf(pt.getX()));
                                       latVal.setText(String.valueOf(pt.getY()));
                                       altVal.setText(String.valueOf(""));
                                       featIdVal.setText(s.getKey().getFeatureId());
                                   }

                                   for (final String key : s.getProperties().keySet()) {
                                       TableRow tr = new TableRow(FeatureDetailsFragment.this.getContext());
                                       tr.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       TextView tv = new TextView(FeatureDetailsFragment.this.getContext());
                                       tv.setText(key);
                                       tv.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tr.addView(tv);
                                       EditText tvValue = new EditText(FeatureDetailsFragment.this.getContext());
                                       tvValue.setText(String.valueOf(s.getProperties().get(key)));
                                       tvValue.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tvValue.setPadding(20, 3, 0, 3);
                                       tvValue.setInputType(InputType.TYPE_CLASS_TEXT);
                                       tvValue.setImeOptions(EditorInfo.IME_ACTION_DONE);
                                       tvValue.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                                           @Override
                                           public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                                               boolean handled = false;
                                               if (actionId == EditorInfo.IME_ACTION_DONE) {
                                                   updateFeaturePropertyValue(key, v.getText().toString());
                                                   handled = true;
                                               }
                                               return handled;
                                           }
                                       });

                                       tr.addView(tvValue);
                                       table.addView(tr, new TableLayout.LayoutParams(TableLayout.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));

                                       }

                                   }
                           }

                );

    }

    private void updateFeaturePropertyValue(String propertyKey, String propertyValue) {
        // first determine which store we need to write to
        SCServiceManager serviceManager =  SpatialConnectService.getInstance().getServiceManager(getContext());
        SCDataStore ds = serviceManager.getDataService().getStoreById(selectedFeature.getKey().getStoreId());
        // then update the feature's property with the new value
        selectedFeature.getProperties().put(propertyKey, propertyValue);
        // and save the updated feature back to the store
        ds.update(selectedFeature).subscribe(new Action1<Boolean>() {
            @Override
            public void call(Boolean updated) {
                // if true then we saved and can react to it
                Log.d("FeatureDetailsFragment", "feature was updated");
                // hide virtual keyboard
                InputMethodManager imm = (InputMethodManager) getContext()
                        .getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(latVal.getWindowToken(), InputMethodManager.RESULT_UNCHANGED_SHOWN);
            }
        });
    }

    private void updatePoint(double lat, double lon) {
        // first determine which store we need to write to
        SCServiceManager serviceManager =  SpatialConnectService.getInstance().getServiceManager(getContext());
        SCDataStore ds = serviceManager.getDataService().getStoreById(selectedFeature.getKey().getStoreId());
        // then update the feature's geometry with the new value
        GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);
        selectedFeature.setGeometry(geometryFactory.createPoint(new Coordinate(lon, lat)));
        // and save the updated feature back to the store
        ds.update(selectedFeature).subscribe(new Action1<Boolean>() {
            @Override
            public void call(Boolean updated) {
                // if true then we saved and can react to it
                Log.d("FeatureDetailsFragment", "feature was updated");
                // hide virtual keyboard
                InputMethodManager imm = (InputMethodManager) getContext()
                        .getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(latVal.getWindowToken(), InputMethodManager.RESULT_UNCHANGED_SHOWN);
            }
        });
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        map = googleMap;

        LatLng featurePoint = new LatLng(this.lat, this.lon);

        // center the map on the position of the selected feature
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(featurePoint, 15));

        // add a callback to update the feature when the map center is updated
        map.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {
            @Override
            public void onCameraChange(CameraPosition cameraPosition) {
                lonVal.setText(String.valueOf(cameraPosition.target.longitude));
                latVal.setText(String.valueOf(cameraPosition.target.latitude));
                if (selectedFeature != null) {
                    updatePoint(cameraPosition.target.latitude, cameraPosition.target.longitude);
                }
            }
        });
    }

}
