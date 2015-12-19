package com.boundlessgeo.spatialconnect.app;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import com.boundlessgeo.spatialconnect.geometries.SCBoundingBox;
import com.boundlessgeo.spatialconnect.geometries.SCGeometry;
import com.boundlessgeo.spatialconnect.geometries.SCPoint;
import com.boundlessgeo.spatialconnect.geometries.SCSpatialFeature;
import com.boundlessgeo.spatialconnect.query.SCGeometryPredicateComparison;
import com.boundlessgeo.spatialconnect.query.SCPredicate;
import com.boundlessgeo.spatialconnect.query.SCQueryFilter;
import com.boundlessgeo.spatialconnect.services.SCServiceManager;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;
import com.vividsolutions.jts.geom.Point;

import org.w3c.dom.Text;

import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

/**
 * A placeholder fragment containing a simple view.
 */
public class FeatureDetailsFragment extends Fragment {

    private String featureId,layerId,storeId;
    private double lat,lon;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        Bundle b = getActivity().getIntent().getExtras();
        lat = (double)b.get("lat");
        lon = (double)b.get("lon");
        this.featureId = (String)b.get("fid");
        this.layerId = (String)b.get("lid");
        this.storeId = (String)b.get("sid");
        return inflater.inflate(R.layout.fragment_feature_details, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        SCServiceManager serviceManager =  SpatialConnectService.getInstance().getServiceManager(getContext());
        SCDataStore ds = serviceManager.getDataService().getStoreById(storeId);

        int auth = ds.getAuthorization();

        final TextView storeIdVal = (TextView)getView().findViewById(R.id.feature_detail_store_value);
        final TextView layerVal = (TextView)getView().findViewById(R.id.feature_detail_layer_value);
        final TextView lonVal = (TextView)getView().findViewById(R.id.feature_detail_lon_value);
        final TextView latVal = (TextView)getView().findViewById(R.id.feature_detail_lat_value);
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
                               public void onNext(SCGeometry s) {
                                   storeIdVal.setText(s.getKey().getStoreId());
                                   layerVal.setText(s.getKey().getLayerId());
                                   if (s instanceof SCPoint) {
                                       SCPoint p = (SCPoint)s;
                                       Point pt = (Point)p.getGeometry();
                                       lonVal.setText(String.valueOf(pt.getX()));
                                       latVal.setText(String.valueOf(pt.getY()));
                                       altVal.setText(String.valueOf(""));
                                       featIdVal.setText(s.getKey().getFeatureId());
                                   }

                                   for (String key : s.getProperties().keySet()) {
                                       TableRow tr = new TableRow(FeatureDetailsFragment.this.getContext());
                                       tr.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       TextView tv = new TextView(FeatureDetailsFragment.this.getContext());
                                       tv.setText(key);
                                       tv.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tr.addView(tv);
                                       TextView tvValue = new TextView(FeatureDetailsFragment.this.getContext());
                                       tvValue.setText(String.valueOf(s.getProperties().get(key)));
                                       tvValue.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));
                                       tvValue.setPadding(20,3,0,3);
                                       tr.addView(tvValue);
                                       table.addView(tr, new TableLayout.LayoutParams(TableLayout.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT));

                                   }

                               }
                           }

                );

    }
}
