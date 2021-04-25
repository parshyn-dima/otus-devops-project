### Предварительная подготовка для запуска инфраструктуры проекта

**Необходимо иметь действующий аккаунт в Yandex Cloud**
https://cloud.yandex.ru/docs/cli/quickstart

```
git clone https://gitlab.dparshin.ru/otus_devops_project/app.git
cd app
```

Для запуска проекта необходимо внести свои данные в файлы конфигурации и переименовать их, удалив из названия .example:
1) infra/terraform/terraform.tfvars.example
   ```
   yc config list
   yc vpc network list
   yc vpc subnet list
   ```
   Для удобства настройки проекта, были зарезервированы два "белых" IP. Данные IP необходимо
   указать как параметры для переменных ip_bastion и ip_loadbalancer в terraform.tfvars.

2) infra/terraform/key.json.example
   Создание сервисного аккаунта.
   ```
   yc config list
   export SVC_ACCT=<service_account>
   export FOLDER_ID=<folder_id>
   yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
   ACCT_ID=$(yc iam service-account get $SVC_ACCT | grep ^id | awk '{print $2}')
   yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor \
   --service-account-id $ACCT_ID
   yc iam key create --service-account-id $ACCT_ID --output ./key.json
   ```
3) infra/ansible/roles/swarm/.env.example
4) На ПК с которого будет запускаться проект необходимо создать файл config в директории
   ~/.ssh/.
   ```
   Host    bastion
           hostname <ip_bastion>
   Host    master-*
           ProxyJump bastion
   Host    node-*
           ProxyJump bastion
   Host *
           user ubuntu
           ForwardAgent yes
           ControlMaster auto
           ControlPersist 5
           StrictHostKeyChecking no
           UserKnownHostsFile=/dev/null
   ```

### Запуск инфраструктуры проекта

После выполнения предварительной подготовки возможен запуск инфраструктуры проекта. Для этого необходимо перейти в каталог terraform и выполнить следующие команды:
```
terraform init
terraform plan
terraform apply -auto-approve
```

После развертывания инфраструктуры приложение будет доступно по адресу
```
http://<ip_loadbalancer>
```
web console RabbitMQ
```
http://<ip_loadbalancer>:15672
```
