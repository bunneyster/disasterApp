# Better Cup - Intel Edison Board Code

The code running on the Edison board for the Better Cup project.


## Installation

SSH on the Edison, and run the commands below to install Intel's MRAA and UPM
libraries.

```bash
echo "src maa-upm http://iotdk.intel.com/repos/1.1/intelgalactic" > /etc/opkg/intel-iotdk.conf
opkg update
opkg upgrade
```

While SSHed on the Edison, point it to your test server, for development.

```bash
mkdir -p ~/.edison-cup
echo "http://192.168.2.2:3000" > ~/.edison-cup/server.url
```


## License

This project is Copyright (c) 2015 Victor Costan and Staphany Park, and
distributed under the MIT License.
