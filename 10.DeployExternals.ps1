Clear-Host

./kubectl apply -f ./volumes/azurestorage/mssql.yaml
./kubectl apply -f ./volumes/azurestorage/redis.yaml
./kubectl apply -f ./volumes/azurestorage/solr.yaml
./kubectl apply -k ./external/
# ./kubectl get pods -o wide
# ./kubectl wait --for=condition=Available deployments --all --timeout=900s
# ./kubectl wait --for=condition=Ready pods --all



#Open a Command Prompt, then execute this command on MSSQL Container to Give full access to data folder

#icacls "c:\data" /q /c /t /grant Users:F

#F gives Full Access.   /q /c /t applies the permissions to subfolders.