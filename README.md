# `libamrfile`

This repository contains a build of the `libamrfile.so` library and Python
bindings, within the [amrfile](amrfile/) directory, as well as the build
script `build.sh` which was used to build `libamrfile.so` from the BISICLES
source.

More information regarding `libamrfile` can be found here:

[http://davis.lbl.gov/Manuals/BISICLES-DOCS/libamrfile.html](http://davis.lbl.gov/Manuals/BISICLES-DOCS/libamrfile.html)

`libamrfile.so` was build on a CentOS 6 system, with version 4.8.1 of the GCC
compilers.

BISICLES and Chombo are released under the [Chombo license](LICENSE).

BISICLES version:

```
r3925 | dmartin | 2020-05-04 09:34:38 +0100 (Mon, 04 May 2020) | 3 lines

first cut at all sectors done...
```

Chombo version:

```
r23611 | dmartin | 2019-08-05 20:58:03 +0100 (Mon, 05 Aug 2019) | 3 lines

added patch8 branch, which is copied from the 3.2.patch7 branch...
```

BISICLES build instructions can be found here:

[http://davis.lbl.gov/Manuals/BISICLES-DOCS/readme.html](http://davis.lbl.gov/Manuals/BISICLES-DOCS/readme.html)

BISICLES and Chombo source can be checked out with:

```
svn co https://anag-repo.lbl.gov/svn/BISICLES/public/trunk
svn co https://anag-repo.lbl.gov/svn/Chombo/release/3.2.patch8
```

This requires an account, which can be obtained here:

[https://anag-repo.lbl.gov/](https://anag-repo.lbl.gov/)
