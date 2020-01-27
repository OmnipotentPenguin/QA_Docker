#!/bin/bash

echo "Please enter new filename"
read inputName

touch $inputName

chmod +x $inputName

echo '#!/bin/bash' >> $inputName

nano $inputName

