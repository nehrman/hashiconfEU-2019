#!/bin/bash

set -e 

export MONGODB_USER=$(kubectl get secret/mongodb -o jsonpath="{.data.database-user}" | base64 -D)
export MONGODB_PWD=$(kubectl get secret/mongodb -o jsonpath="{.data.database-password}" | base64 -D)

vault write  kv/fruits-catalog-mongodb user=$MONGODB_USER password=$MONGODB_PWD