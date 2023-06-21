Clear-Host

$namespace = "sitecore"

./kubectl create ns $namespace

#select the current namespace
./kubectl config set-context --current --namespace=$namespace