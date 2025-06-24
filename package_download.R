# Set environment variables to point to OSGeo4W libraries
Sys.setenv(
  PATH = paste("C:/OSGeo4W64/bin", Sys.getenv("PATH"), sep = ";"),
  PROJ_LIB = "C:/OSGeo4W64/share/proj",
  GDAL_DATA = "C:/OSGeo4W64/share/gdal",
  GEOS_DIR = "C:/OSGeo4W64",
  PROJ_DATA = "C:/OSGeo4W64/share/proj",
  PKG_CONFIG_PATH = "C:/OSGeo4W64/lib/pkgconfig"
)

# Clean up any old sf builds
remove.packages("sf")

# Reinstall sf using configure.args to point to correct GDAL, GEOS, and PROJ
install.packages("sf", type = "source",
                 configure.args = "--with-gdal-config=C:/OSGeo4W64/bin/gdal-config --with-geos-config=C:/OSGeo4W64/bin/geos-config --with-proj-include=C:/OSGeo4W64/include"
)

