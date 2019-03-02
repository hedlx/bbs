echo '$ pwd'
pwd
echo "rc: $?"

echo '$ ls backend/target/debug/backend'
ls -l backend/target/debug/backend
echo "rc: $?"

echo '$ date > date.txt'
date > date.txt
echo "rc: $?"

echo '$ openssl'
openssl aes-256-cbc -K $encrypted_db197bbd43df_key -iv $encrypted_db197bbd43df_iv -in travis/ssh-key.enc -out travis/ssh-key -d
echo "rc: $?"

echo '$ $secret_ssh -i travis/ssh-key ls'
ssh -q hedlx.org -p 359 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i travis/ssh-key ls
echo "rc: $?"
