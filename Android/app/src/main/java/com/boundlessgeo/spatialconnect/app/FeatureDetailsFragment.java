package com.boundlessgeo.spatialconnect.app;

import android.app.Fragment;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
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
import com.boundlessgeo.spatialconnect.stores.SCKeyTuple;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;

import rx.Observable;
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
    private SCServiceManager serviceManager;
    private SCDataStore ds;
    private GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);
    private static final String LOG_TAG = FeatureDetailsFragment.class.getName();

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

        // initialize the map
        mapView = (MapView) inflatedView.findViewById(R.id.edit_point_map);
        mapView.onCreate(savedInstanceState);
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
        serviceManager =  SpatialConnectService.getInstance().getServiceManager(getActivity());
        ds = serviceManager.getDataService().getStoreById(storeId);

        SCDataStore.DataStorePermissionEnum auth = ds.getAuthorization();

        final TextView storeIdVal = (TextView)getView().findViewById(R.id.feature_detail_store_value);
        final TextView layerVal = (TextView)getView().findViewById(R.id.feature_detail_layer_value);
        lonVal = (TextView)getView().findViewById(R.id.feature_detail_lon_value);
        latVal = (TextView)getView().findViewById(R.id.feature_detail_lat_value);
        final TextView altVal = (TextView)getView().findViewById(R.id.feature_detail_alt_value);
        final TextView featIdVal = (TextView)getView().findViewById(R.id.feature_detail_featureid_value);
        final TableLayout table = (TableLayout)getView().findViewById(R.id.feature_detail_prop_table);

        SCKeyTuple keyTuple = new SCKeyTuple(storeId,layerId,featureId);
        final String type = ds.getType();

        Observable obs;

        if (type.equalsIgnoreCase("geojson")) {
            SCBoundingBox bbox = new SCBoundingBox(lon,lat,lon,lat);
            SCPredicate p = new SCPredicate(bbox, SCGeometryPredicateComparison.SCPREDICATE_OPERATOR_WITHIN);
            SCQueryFilter filter = new SCQueryFilter(p);
            obs = ds.query(filter);
        } else {
            obs = ds.queryById(keyTuple);
        }

        obs.subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
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
                                       TableRow tr = new TableRow(getActivity());
                                       tr.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       TextView tv = new TextView(getActivity());
                                       tv.setText(key);
                                       tv.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tr.addView(tv);
                                       TextView tvValue = new TextView(getActivity());
                                       if (featureIsEditable()) {
                                           tvValue = new EditText(getActivity());
                                           tvValue.setInputType(InputType.TYPE_CLASS_TEXT);
                                           tvValue.setImeOptions(EditorInfo.IME_ACTION_DONE);
                                           tvValue.addTextChangedListener(new TextWatcher() {

                                               @Override
                                               public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                                               }

                                               @Override
                                               public void onTextChanged(CharSequence s, int start, int before, int count) {
                                               }

                                               @Override
                                               public void afterTextChanged(Editable s) {
                                                   // update selected feature with property
                                                   selectedFeature.getProperties().put(
                                                           key,
                                                           s.toString()
                                                   );
                                               }
                                           });
                                           // add callback to the delete button
                                           final Button deleteButton =
                                                   (Button) getView().findViewById(R.id.delete_button);
                                           deleteButton.setVisibility(View.VISIBLE);
                                           deleteButton.setOnClickListener(new View.OnClickListener() {
                                               public void onClick(View v) {
                                                   // delete the selected feature
                                                   ds.delete(selectedFeature.getKey()).subscribe(new Action1<Boolean>() {
                                                       @Override
                                                       public void call(Boolean deleted) {
                                                           Log.d(LOG_TAG, "feature was deleted");
                                                           // change back to map fragment
                                                           getActivity().finish();
                                                       }
                                                   });
                                               }
                                           });
                                           // add callback to the update button
                                           final Button updateButton =
                                                   (Button) getView().findViewById(R.id.update_button);
                                           updateButton.setVisibility(View.VISIBLE);
                                           updateButton.setOnClickListener(new View.OnClickListener() {
                                               public void onClick(View v) {
                                                   // update the feature's geometry with the new value
                                                   LatLng center = map.getCameraPosition().target;
                                                   selectedFeature.setGeometry(
                                                           geometryFactory.createPoint(
                                                                   new Coordinate(center.longitude, center.latitude)
                                                           )
                                                   );
                                                   ds.update(selectedFeature).subscribe(new Action1<Boolean>() {
                                                       @Override
                                                       public void call(Boolean updated) {
                                                           Log.d(LOG_TAG, "feature was updated");
                                                           // change back to map fragment
                                                           getActivity().finish();
                                                       }
                                                   });
                                               }
                                           });
                                       }
                                       tvValue.setText(String.valueOf(s.getProperties().get(key)));
                                       tvValue.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tvValue.setPadding(20, 3, 0, 3);
                                       tr.addView(tvValue);
                                       table.addView(tr, new TableLayout.LayoutParams(TableLayout.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                   }
                               }
                           }
                );
    }

    private boolean featureIsEditable() {
        return ds.getAuthorization().equals(SCDataStore.DataStorePermissionEnum.READ_WRITE);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        map = googleMap;

        LatLng featurePoint = new LatLng(this.lat, this.lon);

        // center the map on the position of the selected feature
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(featurePoint, 15));


        if (featureIsEditable()) {
            map.getUiSettings().setZoomGesturesEnabled(true);
            map.getUiSettings().setScrollGesturesEnabled(true);
            map.getUiSettings().setZoomControlsEnabled(true);
            // add a callback to update the selectedFeature's geometry when the map center is updated
            map.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {
                @Override
                public void onCameraChange(CameraPosition cameraPosition) {
                    lonVal.setText(String.valueOf(cameraPosition.target.longitude));
                    latVal.setText(String.valueOf(cameraPosition.target.latitude));
                    map.clear();
                    map.addMarker(new MarkerOptions().position(cameraPosition.target));
                }
            });
        } else {
            map.getUiSettings().setScrollGesturesEnabled(false);
        }

    }

}
