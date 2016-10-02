package com.devworms.salva.minutas;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class CategoriasFragment extends Fragment {
    private ListView list;
    private String[] categorias = {"Propusta", "Reporte Bimestral", "Reporte Anual", "Analisis de Producto"};
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_categorias, container, false);

        list = (ListView)rootView.findViewById(R.id.listCategorias);

        ArrayAdapter<String> adaptador = new ArrayAdapter<String>(getActivity().getBaseContext(), android.R.layout.simple_list_item_1, categorias);

        list.setAdapter(adaptador);
        return rootView;
    }
}
