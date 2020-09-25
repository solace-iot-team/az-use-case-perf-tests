# SDK Perf Image

By default, it uses this modified [SDK Perf](./sdkperf-c-x64).

In order to use a different one, change the link `sdkperf-c-x64` and create a script
in the directory that calls it.

Example:
````bash
#!/bin/bash

basedir=`dirname $0`

cd $basedir

./sdkperf_c $*

````

---
The End.
