# SDK Perf Image

By default, the project uses this modified [SDK Perf](../../../bin/sdkperf_c_7.14.0.8).

**The test framework will call: `sdkperf-c-x64/sdkperf_c.sh`.**


### Using a different distribution

For example, download the official distribution:
- download: https://products.solace.com/download/SDKPERF_C_LINUX64
- unzip the tar.gz
````bash
cp {path}/pubSubTools ./sdk-perf-image/sdkperf-c-x64
# or create a link
cd sdk-perf-image
ln -s {path}/pubSubTools sdkperf-c-x64
cd ..
````

Create the script:
- script name: `sdkperf_c.sh`
````bash
cd ./sdk-perf-image/sdkperf-c-x64
vi sdkperf_c.sh
````
- script contents:

  ````bash
  #!/usr/bin/env bash
  basedir=`dirname $0`
  cd $basedir
  ./sdkperf_c $*
  ````


---
The End.
