 #!/bin/bash
pushd $(dirname $0)
sudo xc3sprog -c ftdi '../textmode/Hello.bit'