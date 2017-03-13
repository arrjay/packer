#!/bin/sh

# replace im= attribute in getty with build info
sed -i.dist -e 's/im=.*:/im=\\r\\n\%s\/\%m EFW Build '$BUILD_SHA' (\\%t)\\r\\n\\r\\n:/' /etc/gettytab
