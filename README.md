# Итоговый проект по курсу «DevOps практики и инструменты»
# Создание процесса непрерывной поставки для приложения с применением практик CI/CD и быстрой обратной связью

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
