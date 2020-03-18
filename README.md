# Flow_Direction_Correction

Flow direction toolkit: Matlab scripts for flow direction corrections

Software for manually correcting flow directions derived from a DEM using GIS tools such as ArcMap or GRASS GIS. Plots flow directions along with river centerlines and allows the user to make manual corrections.

## Inputs
flow direction raster, river centerlines shapefile, gauge coordinates (optional)

### Flow direction convention
Follows the VIC routing model (Lohmann et al., 1998) convention for flow directions. See http://www.hydro.washington.edu/Lettenmaier/Models/VIC/Documentation/Routing/FlowDirection.shtml

* 1 - N
* 2 - NE
* 3 - E
* 4 - SE
* 5 - S
* 6 - SW
* 7 - W
* 8 - NW

## Sample data
Includes two sets of sample data: one using geographic coordinates and one using no coordinate system in particular, but which can be used for projected coordinate systems.
