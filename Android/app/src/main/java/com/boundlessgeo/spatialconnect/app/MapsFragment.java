package com.boundlessgeo.spatialconnect.app;

import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.boundlessgeo.spatialconnect.geometries.SCBoundingBox;
import com.boundlessgeo.spatialconnect.geometries.SCGeometry;
import com.boundlessgeo.spatialconnect.geometries.SCSpatialFeature;
import com.boundlessgeo.spatialconnect.query.SCGeometryPredicateComparison;
import com.boundlessgeo.spatialconnect.query.SCPredicate;
import com.boundlessgeo.spatialconnect.query.SCQueryFilter;
import com.boundlessgeo.spatialconnect.scutilities.GoogleMapsUtil;
import com.boundlessgeo.spatialconnect.services.SCDataService;
import com.boundlessgeo.spatialconnect.stores.GeoPackageStore;
import com.boundlessgeo.spatialconnect.stores.SCDataStore;
import com.boundlessgeo.spatialconnect.stores.SCKeyTuple;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.vividsolutions.jts.geom.Point;

import java.util.HashMap;

import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;


public class MapsFragment extends Fragment implements OnMapReadyCallback {

    private GoogleMap map; // Might be null if Google Play services APK is not available.
    private MainActivity mainActivity;
    private MapFragment mapFragment;
    private SCDataService dataService;

    HashMap<String, SCKeyTuple> mMarkers = new HashMap<>();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_main, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        if (mainActivity == null) {
            mainActivity = (MainActivity) getActivity();
        }
        if (mapFragment == null) {
            mapFragment = MapFragment.newInstance();;
        }
        mainActivity.getFragmentManager().beginTransaction().add(R.id.container, mapFragment).commit();
        dataService = SpatialConnectService.getInstance().getServiceManager(getActivity()).getDataService();
        setUpMapIfNeeded();
    }

    @Override
    public void onAttach(Context activity) {
        super.onAttach(activity);
        mainActivity = (MainActivity) getActivity();
        mapFragment = MapFragment.newInstance();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only
     * ever call {@link #setUpMap()} once when {@link #map} is not null.
     */
    protected void setUpMapIfNeeded() {
        if (map == null) {
            mapFragment.getMapAsync(this);
        }
    }

    protected void setUpMap() {
//        map.setMyLocationEnabled(true);
//        map.getUiSettings().setMyLocationButtonEnabled(true);
//        map.setOnMyLocationButtonClickListener(new LocationHelper(mainActivity, map));
        map.getUiSettings().setZoomControlsEnabled(true);
        map.setOnInfoWindowClickListener(new GoogleMap.OnInfoWindowClickListener() {
            @Override
            public void onInfoWindowClick(Marker marker) {
                Intent intent = new Intent(MapsFragment.this.getActivity(), FeatureDetailsActivity.class);
                intent.putExtra("lat", marker.getPosition().latitude);
                intent.putExtra("lon", marker.getPosition().longitude);
                SCKeyTuple kt = mMarkers.get(marker.getId());
                intent.putExtra("sid", kt.getStoreId());
                intent.putExtra("lid", kt.getLayerId());
                intent.putExtra("fid", kt.getFeatureId());
                mMarkers.get(marker.getId());
                startActivity(intent);
            }
        });
    }


    private void loadFeatures(SCBoundingBox bbox) {
        // apply predicate to filter
        SCQueryFilter filter = new SCQueryFilter(
                new SCPredicate(bbox, SCGeometryPredicateComparison.SCPREDICATE_OPERATOR_WITHIN)
        );

        dataService.queryAllStores(filter)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        new Subscriber<SCSpatialFeature>() {
                            SCSpatialFeature latestFeature;

                            @Override
                            public void onCompleted() {
                                Log.d("MapsFragment.Subscriber", "query observable completed");
                            }

                            @Override
                            public void onError(Throwable e) {
                                e.printStackTrace();
                                Log.e("MapsFragment.Subscriber", "onError()\n" + e.getLocalizedMessage());
                            }

                            @Override
                            public void onNext(SCSpatialFeature feature) {
                                if (feature instanceof SCGeometry && ((SCGeometry) feature).getGeometry() != null) {
                                    latestFeature = feature;
                                    // only put points in the mMarkers b/c we will only edit those for now
                                    if (((SCGeometry) feature).getGeometry() instanceof Point) {
                                        Marker m = GoogleMapsUtil.addPointToMap(map, (SCGeometry) feature);
                                        mMarkers.put(m.getId(), feature.getKey());
                                    } else {
                                        GoogleMapsUtil.addToMap(map, (SCGeometry) feature);
                                    }
                                }
                            }
                        }
                );
    }

    public void loadImagery() {
        SCDataStore selectedStore = dataService.getStoreById("ba293796-5026-46f7-a2ff-e5dec85heh6b");
        GeoPackageStore geoPackageStore = (GeoPackageStore)
                SpatialConnectService.getInstance().getServiceManager(getActivity())
                .getDataService()
                .getStoreById(selectedStore.getStoreId());

        geoPackageStore.addGeoPackageTileOverlay(
                map,
                selectedStore.getAdapter().getDataStoreName(),
                "WhiteHorse"
        );
        CameraUpdate cu = CameraUpdateFactory.newLatLngZoom(new LatLng(60.86, -135.19), 16);
        map.animateCamera(cu);
    }

    private SCBoundingBox getCurrentBoundingBox() {
        LatLng ne = this.map.getProjection().getVisibleRegion().latLngBounds.northeast;
        LatLng sw = this.map.getProjection().getVisibleRegion().latLngBounds.southwest;
        SCBoundingBox bbox = new SCBoundingBox(sw.longitude, sw.latitude, ne.longitude, ne.latitude);
        return bbox;
    }

    public void reloadFeatures() {
        map.clear();
        loadFeatures(getCurrentBoundingBox());
    }

    @Override
    public void onMapReady(GoogleMap map) {
        this.map = map;
        setUpMap();
        reloadFeatures();
    }

}
