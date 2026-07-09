# sasktran-manylinux2014-build-container
Build container used to build the SASKTRAN radiative transfer model on a manylinux2014 platform

## Release Notes

**2026-07-03**: Upgraded from manylinux2014 which reached end-of-life on 2024-06-30 to [manylinux_2_28](https://github.com/pypa/manylinux) which should provide good support for some time to come.

            OpenBLAS -> 0.3.18
            Eigen -> 3.4.1
            Boost -> 1.82.0
            Zlib -> 1.3.2
            hdf5 -> 1.12.1
            netcdf -> 4.8.1
            yaml-cpp -> 0.9.0
            Catch2 -> 3.15.1
The 
