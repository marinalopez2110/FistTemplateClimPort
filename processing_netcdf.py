import geopandas as gpd
import xarray as xr
import matplotlib.pyplot as plt
import pandas as pd
import pathlib
import xarray as xr
import geopandas as gpd
from shapely.geometry import Point
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
import glob
import itertools
import processing_netcdf as pcdf
from shapely import geometry as gmty


#Load NETCDF as dataframe and return with model and percentile columns
def load_as_df(filename):
    ds = xr.open_dataset(filename)
    index = ds.indexes['time']
    if index.dtype != "<M8[ns]":
        ds['time'] = index.to_datetimeindex()
    df = ds.to_dataframe().dropna()
    return df



#Load NETCDF as dataframe
def load_as_df(filename):
    ds = xr.open_dataset(filename)
    index = ds.indexes['time']
    if index.dtype != "<M8[ns]":
        ds['time'] = index.to_datetimeindex()
    df = ds.to_dataframe().dropna()
    return df


#### Get data from the 11 models by periods . temp = tg_mean, tmax or tmin. Returns a tupple
def dft_map_models_periods(filename, temp):
    #Convert NetCDF into a dataframe
    df = load_as_df(filename)
    #Convert temperature into Celsius
    dfC = df.copy()
    dfC[temp] = dfC[temp] -273.15
    #Define 3 periods of time: 
    year_groups = {y:0 for y in range(1980,2011)}
    year_groups.update({y:1 for y in range(2041,2071)})
    year_groups.update({y:2 for y in range(2071,2101)})
    #Get the mean of every period
    dfC2 = dfC.reset_index()
    dfp = dfC2.groupby([dfC2.time.dt.year.map(year_groups), "lat","lon"]).mean()
    
    ##Data Frame for Historic Period
    df_h = dfp.query("time==0.0")
    df_h = df_h.reset_index()
    
    ##Data Frame for Period 2040-2070
    df2050 = dfp.query("time==1.0")
    df2050 = df2050.reset_index()
    
    ##Data Frame for Period 2071-20100
    df2080 = dfp.query("time==2.0")
    df2080 = df2080.reset_index()
    return (df_h, df2050, df2080)


### Converts 11 (in path) models from lat,lon to GeoDF with gemetry points
def data_to_points(path, variable):
    
    # Path to files
    files = list(glob.glob(os.path.join(path,variable)))
    datasets = [xr.open_dataset(f) for f in files]
    latlon_df_0 = pd.concat(pd.DataFrame(itertools.product(ds.lat.values, ds.lon.values), columns=["lat","lon"]) 
                            for ds in datasets).drop_duplicates(["lat","lon"])
    latlon_df = gpd.GeoDataFrame(latlon_df_0)
    latlon_df["geometry"] = [Point(lon, lat) for (lat,lon) in zip(latlon_df.lat, latlon_df.lon)]
    return latlon_df

### Converts 1 file from lat,lon to GeoDF with gemetry points
def dataf_to_points(file):
    
    # Path to files
    datasets = xr.open_dataset(file)
    latlon_df_0 = pd.concat(pd.DataFrame(itertools.product(ds.lat.values, ds.lon.values), columns=["lat","lon"]) 
                            for ds in datasets).drop_duplicates(["lat","lon"])
    latlon_df = gpd.GeoDataFrame(latlon_df_0)
    latlon_df["geometry"] = [Point(lon, lat) for (lat,lon) in zip(latlon_df.lat, latlon_df.lon)]
    return latlon_df

### Converts points into polygons
def process_points_poly(dfpoints):
    arr = dfpoints.lon.unique()
    arr.sort()
    dlon = np.diff(arr)[0] / 2
    arr = dfpoints.lat.unique()
    arr.sort()
    dlat = np.diff(arr)[0] / 2
    (dlon, dlat)
    dfpoints.geometry = [gmty.Polygon([[lon-dlon, lat-dlat], [lon+dlon, lat-dlat], [lon+dlon, lat+dlat],
                                       [lon-dlon, lat+dlat]]) 
                         for (lat, lon) in zip(dfpoints.lat, dfpoints.lon)]
    return dfpoints.geometry

### Makes grid (polygons) to clip non-processed data into regions
def make_grid(grid, path_filename_shapefile):
    shapefile = pathlib.Path(path_filename_shapefile)
    shape0 = gpd.read_file(shapefile)
    #Reading Shapefiles in right coordinate system
    shape = shape0[shape0.geometry.type == 'Polygon'].to_crs({'init': 'epsg:4326'})
    #dfpolyclip = gpd.sjoin(grid, shape, op="intersects")
    dfpolyclip = gpd.overlay(grid, shape, how="intersection")
    return dfpolyclip


### Procesing periods to merge with data
def proc_period(tuplen, period):
    #Extract df from tuple
    dfp = pd.DataFrame.from_records(tuplen[period], columns= ["time", "lat", "lon", "tg_mean"] )
    dfp = dfp.reset_index()
    dfp.set_index(["lat","lon"])
    return(dfp)







### Getting mask to clip non-processed data into regions with points geometry only
def latlon_regions(path_filename_shapefile):
    # Path to files
    path = "/home/mlopez/EXEC/Tg_annual_11_models/"
    json = pathlib.Path(path_filename_shapefile)
    files = list(glob.glob(os.path.join(path,'*.*')))
    datasets = [xr.open_dataset(f) for f in files]
    latlon_df_0 = pd.concat(pd.DataFrame(itertools.product(ds.lat.values, ds.lon.values), columns=["lat","lon"]) 
                            for ds in datasets).drop_duplicates(["lat","lon"])
    latlon_df = gpd.GeoDataFrame(latlon_df_0)
    latlon_df["geometry"] = [Point(lon, lat) for (lat,lon) in zip(latlon_df.lat, latlon_df.lon)]
    shape = gpd.read_file(json)
    #Reading Shapefiles in right coordinate system
    shape = shape.to_crs({'init': 'epsg:4326'})
    latlon_res = gpd.sjoin(latlon_df, shape, op="within")
    return latlon_res

#### Clipping by region to plot static images   
def clip_by_reg(shapefile, dft):
    latlon_df = pcdf.latlon_regions(shapefile)
    dft.set_index(["lat","lon"])
    latlon_df.set_index(["lat","lon"])
    dfclip = pd.merge(dft, latlon_df, on=["lat","lon"])
    return (dfclip)