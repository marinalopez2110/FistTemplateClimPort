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


#Load NETCDF as dataframe
def load_as_df(filename):
    ds = xr.open_dataset(filename)
    index = ds.indexes['time']
    if index.dtype != "<M8[ns]":
        ds['time'] = index.to_datetimeindex()
    df = ds.to_dataframe().dropna()
    return df


#### Get data from the 11 models by periods 
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

    
#### Clipping by region    
def clip_by_reg(shapefile, dft):
    latlon_df = pcdf.latlon_regions(shapefile)
    dft.set_index(["lat","lon"])
    latlon_df.set_index(["lat","lon"])
    dfclip = pd.merge(dft, latlon_df, on=["lat","lon"])
    return (dfclip)
    

### Getting mask to clip non-processed data into regions
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

