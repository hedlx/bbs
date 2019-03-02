echo '$ ls backend/target'
ls target
echo "rc: $?"

echo '$ date > date.txt'
date > date.txt
echo "rc: $?"

echo '$ pwd; cd; pwd; ls'
pwd; cd; pwd; ls

echo '$ openssl'
openssl aes-256-cbc -K $encrypted_db197bbd43df_key -iv $encrypted_db197bbd43df_iv -in travis/ssh-key.enc -out travis/ssh-key -d
echo 'rc: $?'

echo '$ $secret_ssh -i ssh-key ls'
$secret_ssh -i ssh-key ls
echo "rc: $?"
