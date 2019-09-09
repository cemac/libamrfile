#!/bin/bash

# build libamrfile.so, for use with python
# updated: 2019-09-03
#
# build on a CentOS6 host, for forward compatibility.
#
# bisicles build instructions:
#
#   http://davis.lbl.gov/Manuals/BISICLES-DOCS/readme.html
#
# bisicles and chombo source can be checked out via:
#
#   svn co https://anag-repo.lbl.gov/svn/BISICLES/public/trunk
#   svn co https://anag-repo.lbl.gov/svn/Chombo/release/3.2.patch8
#
# this requires an account, which can be obtained here:
#
#   https://anag-repo.lbl.gov/

# verion information:
#
#  bisicles 20190828: 
#
#    > r3844 | slcornford | 2019-08-28 12:42:20 +0100 (Wed, 28 Aug 2019) | 1 line
#    > 
#    > fix testL1L2 and friends to compile
#
#  chombo 3.2.patch8:
# 
#    > r23611 | dmartin | 2019-08-05 20:58:03 +0100 (Mon, 05 Aug 2019) | 3 lines
#    > 
#    > added patch8 branch, which is copied from the 3.2.patch7 branch...

# source directory:
SRC_DIR=$(readlink -f $(pwd)/../src)
# build directory:
BUILD_DIR=$(pwd)
# where to output directory containing python files + libamrfile.so:
OUT_DIR=${BUILD_DIR}

#  set up modules / environment:
module purge
module load licenses bit gnu/4.8.1 hdf5
# build variables:
CFLAGS='-O2 -fPIC'
CXXFLAGS='-O2 -fPIC'
CPPFLAGS='-O2 -fPIC'
FFLAGS='-O2 -fPIC'
FCFLAGS='-O2 -fPIC'
export CFLAGS CXXFLAGS CPPFLAGS FFLAGS FCFLAGS

# make build directory, and cd:
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# extract bisicles and chombo:
export BISICLES_HOME=${BUILD_DIR}
tar xzf ${SRC_DIR}/bisicles-20190828.tar.gz
tar xzf ${SRC_DIR}/chombo-3.2.patch8.tar.gz
mv bisicles-20190828 BISICLES
mv chombo-3.2.patch8 Chombo

# make definitions:
\cp ${BISICLES_HOME}/BISICLES/docs/Make.defs.local \
  ${BISICLES_HOME}/Make.defs.local
# update configuration ... :
sed -i "s|^\(BISICLES_HOME\).*$|\1 = ${BISICLES_HOME}|g" \
  ${BISICLES_HOME}/Make.defs.local
sed -i "s|^\(MPICXX\).*$|\1 =|g" \
  ${BISICLES_HOME}/Make.defs.local
sed -i "s|^\(HDFINCFLAGS\).*$|\1 = -I${HDF5_HOME}/include|g" \
  ${BISICLES_HOME}/Make.defs.local
HDF5_LIBS="${HDF5_HOME}/lib/libhdf5hl_fortran.a ${HDF5_HOME}/lib/libhdf5_hl.a ${HDF5_HOME}/lib/libhdf5_fortran.a ${HDF5_HOME}/lib/libhdf5.a -lz -ldl"
sed -i "s|^\(HDFLIBFLAGS\).*$|\1 = -L${HDF5_HOME}/lib ${HDF5_LIBS}|g" \
  ${BISICLES_HOME}/Make.defs.local
sed -i "s|^\(HDFMPIINCFLAGS\).*$|\1 =|g" \
  ${BISICLES_HOME}/Make.defs.local
sed -i "s|^\(HDFMPILIBFLAGS\).*$|\1 =|g" \
  ${BISICLES_HOME}/Make.defs.local
ln -s ${BISICLES_HOME}/Make.defs.local \
      ${BISICLES_HOME}/Chombo/lib/mk/Make.defs.local
# '-march=native' seems to cause issues ... :
\cp ${BISICLES_HOME}/Chombo/lib/mk/compiler/Make.defs.GNU \
  ${BISICLES_HOME}/Chombo/lib/mk/compiler/Make.defs.GNU.original
sed -i 's|-march=native||g' \
  ${BISICLES_HOME}/Chombo/lib/mk/compiler/Make.defs.GNU

# build libamrfile:
cd ${BISICLES_HOME}/BISICLES/code/libamrfile
# static link stdc++ and fortran libraries:
\cp GNUmakefile GNUmakefile.original
sed -i "s|\(\$(HDFLIBFLAGS)\)|\1 ${GNU_HOME}/lib64/libstdc++.a ${GNU_HOME}/lib64/libgfortran.a|g" \
  GNUmakefile
make libamrfile.so OPT=TRUE MPI=FALSE USE_PETSC=FALSE

# remove dynamic libstdc++ from requirements:
\cp libamrfile.so libamrfile.so.original
patchelf --remove-needed libstdc++.so.6 libamrfile.so
strip libamrfile.so

# python files:
cd python/AMRFile
/usr/bin/python setup.py build
cp -r build/lib/amrfile ${OUT_DIR}/
cd ../..
cp libamrfile.so ${OUT_DIR}/amrfile/
sed -i 's|^\(import numpy\)|import os\n\1|g' \
  ${OUT_DIR}/amrfile/io.py
sed -i \
  's|^libamrfile = .*$|amr_dir = os.path.dirname(__file__)\namr_lib = "libamrfile.so"\nlibamrfile = CDLL(os.path.sep.join([amr_dir, amr_lib]))|g' \
 ${OUT_DIR}/amrfile/io.py

cd ${OUT_DIR}
chmod 644 amrfile/*
tar czf amrfile.tar.gz amrfile/
