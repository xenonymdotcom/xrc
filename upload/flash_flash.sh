 #!/bin/bash
pushd $(dirname $0)
# upload the flash flasher from https://github.com/jeandet/grlib/tree/master/boards/mini-spartan6p
sudo xc3sprog -c ftdi ./bscan_spi_s6lx25_ftg256.bit 
# now send the image to be written to the flash rom
sudo xc3sprog -c ftdi -I ../XrcCore.bit
