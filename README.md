# Итоговый проект по курсу «DevOps практики и инструменты»
# Создание процесса непрерывной поставки для приложения с применением практик CI/CD и быстрой обратной связью

# [Презентация](https://prezi.com/view/fFY0eX8KteXJxLwUbeMl/)

## Схема проекта

![project_schema](https://github.com/parshyn-dima/screens/blob/master/devops_project/project_schemav3.png)

В качестве проекта взял приложение предоставляемое otus ([UI](https://github.com/express42/search_engine_ui),[CRAWLER](https://github.com/express42/search_engine_crawler)). Данное приложение будет разворачиваться в кластере docker swarm.

Вся инфраструктура развернута в Yandex Cloud.

### Используемые инструменты
1. Создание инфраструктуры — [Terraform](https://www.terraform.io/).
2. Конфигурирование инфраструктуры — [Ansible](https://www.ansible.com/).
3. Процесс CI/CD — [Gitlab](https://about.gitlab.com/).
4. Процесс сбора обратной связи:
    - сбор метрик — [Prometheus](https://prometheus.io/);
    - визуализация — [Grafana](https://grafana.com/);
    - алертинг — [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) + [Slack](https://slack.com/intl/en-ru/).

### Результат выполнения проекта
1. Инфраструктура Yandex Cloud:
    - Load Balancer - балансировщик;
    - Bastion (Jampbox) - доступ к ВМ, не имеющим "белый" IP;
    - NAT-VM - инстанс для доступа ВМ в интернет;
    - Три worker ноды (Node-1..3) и одна нода master (Master-1) кластера docker swarm
    - GitLab
    - ВМ с установленным GitLab Docker Runner
2. Развёрнутые на этой инфраструктуре системы и сервисы:
    - Кластер docker swarm с развернутым приложением crawler, его веб-интерфейсом, базой MongoDB и брокером очередей сообщений RabbitMQ;
    - система для CI/CD;
    - система сбора обратной связи.
3. Настроенный процесс CI/CD:
    - Dockerfiles для создания docker-образов приложения и веб-интерфейса;
    - сервер Gitlab с проектами, включающими репозитории компонентов приложения, и раннером;
    - конвейер, который запускается при внесении изменений в удалённые репозитории компонентов приложения и включает в себя:
        - сборку docker-образа приложения;
        - тестирование работы приложения;
        - ручной запуск деплоя кластера docker swarm с приложением на рабочее окружение из ветки **master** при успешном выполнении всех предыдущих     шагов.
4. Настроенный процесс сбора обратной связи:
    - сбор метрик при помощи Prometheus;
    - визуализация при помощи Grafana;
    - алертинг и отправка оповещений в канал Slack.

## Запуск проекта
### Операционная система и программы

Запуск и работа над проектом выполнялась со следующими программами на ПК с ОС Fedora33 (с другими версия ПО не тестировалось):
    Ansible 2.9.18
    Terraform 0.13.0
    Git 2.30.2
    Yandex Cloud CLI 0.70.0
    
### Предварительная подготовка для запуска инфраструктуры проекта

**Необходимо иметь действующий аккаунт в Yandex Cloud**
https://cloud.yandex.ru/docs/cli/quickstart

```
https://github.com/parshyn-dima/otus-devops-project
cd otus-devops-project
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
    
