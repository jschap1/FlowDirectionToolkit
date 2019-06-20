# Basin delineation and flow direction correction workflow
# June 14, 2019

# Upper Tuolumne Basin

cd /Users/jschap/Documents/Research/SWOTDA_temp/Tuolumne/TuoSub/GIS/grass_workflow
mkdir FlowDirectionToolkit
cd FlowDirectionToolkit
cp ../narivs_merc* .
cp ../na_dem_15s_merc.tif* .
# cp ../bb_merc* .

gdalwarp -te -13489113 4493456 -13269113 4585456 na_dem_15s_merc.tif tuo_dem_15s_merc.tif

r.in.gdal tuo_dem_15s_merc.tif out=dem_fine
r.hydrodem dem_fine out=dem_fine_cond

r.watershed elev=dem_fine_cond drainage=fdir_fine accum=facc_fine

# threshold of 100 cells is 100 km^2 for the 1000 m resolution DEM

r.watershed elev=dem_fine_cond drainage=fdir_fine accum=facc_fine threshold=50 stream=stream_fine_50 --o

# delineate the Upper Tuolumne specifically

# -13304215 4543857 # outlet coordinates, put in a text file

v.in.ascii outlet.txt out=approx_outlet

r.stream.snap approx_outlet out=outlet_snapped stream=stream_fine_50 accum=facc_fine radius=2

# get snapped coordinats
v.out.ascii outlet_snapped out=outlet_snapped.txt
# -13304613|4543957|1

r.stream.basins dir=fdir_fine coordinates=-13304613,4543957 basins=basin_fine

# vectorize the basin

r.to.vect basin_fine out=basin_fine type=area

r.mask basin_fine

r.stream.extract elev=dem_fine_cond accum=facc_fine threshold=50 stream_vector=stream_fine_50 --o

r.mask -r

# Write out files for input into Flow Direction Toolkit

g.region rast=basin_fine

v.out.ogr stream_fine_50 out=stream_fine_50.shp format=ESRI_Shapefile type=line --o
v.out.ogr basin_fine out=basin_fine.shp format=ESRI_Shapefile type=area --o
r.out.ascii fdir_fine out=fdir_fine.asc --o

# Repeat for coarse DEM -------------------------------------------

# Make a coarse DEM

g.region res=5000
r.resamp.stats -w dem_fine out=dem_coarse method=average

r.hydrodem dem_coarse out=dem_coarse_cond

r.watershed elev=dem_coarse_cond drainage=fdir_coarse accum=facc_coarse threshold=2 stream=stream_coarse_50 --o

r.stream.snap approx_outlet out=outlet_snapped_coarse stream=stream_coarse_50 accum=facc_coarse radius=2

# get snapped coordinats
v.out.ascii outlet_snapped_coarse out=outlet_snapped_coarse.txt

r.stream.basins dir=fdir_coarse coordinates=-13306613,4542012.5 basins=basin_coarse

# vectorize the basin

r.to.vect basin_coarse out=basin_coarse type=area

r.mask basin_coarse

r.stream.extract elev=dem_coarse_cond accum=facc_coarse threshold=2 stream_vector=stream_coarse_50 --o

r.mask -r

g.region rast=basin_coarse

v.out.ogr stream_coarse_50 out=stream_coarse_50.shp format=ESRI_Shapefile type=line --o
v.out.ogr basin_coarse out=basin_coarse.shp format=ESRI_Shapefile type=area --o
r.out.gdal fdir_coarse out=fdir_coarse.tif --o
