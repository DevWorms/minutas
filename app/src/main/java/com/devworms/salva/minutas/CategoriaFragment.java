package com.devworms.salva.minutas;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;

import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * Created by sergio on 02/10/16.
 */

public class CategoriaFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.item_categoria, container, false);

     /*   RecyclerView mRecyclerView = (RecyclerView) view.findViewById(R.id.viewRecycle);

        // use this setting to improve performance if you know that changes
        // in content do not change the layout size of the RecyclerView
        mRecyclerView.setHasFixedSize(true);


        // specify an adapter (see also next example)
        CategoriasAdapter mAdapter = new CategoriasAdapter();
        mRecyclerView.setAdapter(mAdapter);
*/
        return view;
    }
}
