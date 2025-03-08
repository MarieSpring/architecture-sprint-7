#!/bin/bash
mkdir -p certs

openssl genrsa -out certs/readonly-user.key 2048
openssl req -new -key certs/readonly-user.key -out certs/readonly-user.csr -subj "/CN=readonly-user/O=readers"
openssl x509 -req -in certs/readonly-user.csr -signkey certs/readonly-user.key -out certs/readonly-user.crt -days 365

openssl genrsa -out certs/configurator-user.key 2048
openssl req -new -key certs/configurator-user.key -out certs/configurator-user.csr -subj "/CN=configurator-user/O=configurators"
openssl x509 -req -in certs/configurator-user.csr -signkey certs/configurator-user.key -out certs/configurator-user.crt -days 365

echo "Пользователи созданы успешно"
