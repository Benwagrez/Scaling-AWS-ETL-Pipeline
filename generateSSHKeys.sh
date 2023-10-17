rm dataserverkey
rm dataserverkey.pub

ssh-keygen -q -t rsa -f ./keys/prod_dataserverkey -N ""
ssh-keygen -p -P "" -N "" -m pem -f ./keys/prod_dataserverkey

ssh-keygen -q -t rsa -f ./keys/dev_dataserverkey -N ""
ssh-keygen -p -P "" -N "" -m pem -f ./keys/dev_dataserverkey