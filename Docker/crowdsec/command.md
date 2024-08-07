sudo docker exec crowdsec cscli bouncers add bouncer-traefik - получение ключа


sudo docker exec crowdsec cscli decisions list - лист заблокированых 

sudo docker exec crowdsec cscli metrics - метрики

sudo docker exec crowdsec cscli decisions add --ip 188.162.15.27 - добавить в черный список

sudo docker exec crowdsec cscli decisions delete --ip 188.162.15.22 - удалить из черного списка


**Настройка белых листов**

Белые списки могут быть очень полезны, особенно в рабочей среде. Если что-то пойдет не так с вашими внутренними связями, у вас будет способ быстро исправить ситуацию. 

Давайте создадим whitelist_custom.yaml file in /opt/crowdsec/parsers/s02-enrich/whitelists_custom.yaml.

```
##https://app.crowdsec.net/hub/author/crowdsecurity/configurations/whitelists
name: crowdsecurity/whitelists
description: "Whitelist events from private ipv4 addresses"
whitelist:
 reason: "private ipv4/ipv6 ip/ranges"
 ip:
   - "127.0.0.1"
   - "::1"
 cidr:
   - "192.168.0.0/16"
   - "10.0.0.0/8"
   - "172.16.0.0/12"

```

**Увеличение часов блокировки**

В crowdsec/config/profiles

Раскоментируем строку: duration_expr: Sprintf('%dh', (GetDecisionsCount(Alert.GetValue()) + 1) * 4)

Повторные баны будут добавлять время блокировки +4 часа

**Включение уведомлений для Gottify**

В файле вашего профиля (по умолчанию /etc/crowdsec/profiles.yaml) , раскомментируйте раздел 

```
#notifications:
# - http_default 
```

Добавляем конфигурацию плагина. По умолчанию будет конфигурация http по адресу /etc/crowdsec/notifications/http.yaml

```
type: http          # Don't change
name: http_default # Must match the registered plugin in the profile

# One of "trace", "debug", "info", "warn", "error", "off"
log_level: info

# group_wait:         # Time to wait collecting alerts before relaying a message to this plugin, eg "30s"
# group_threshold:    # Amount of alerts that triggers a message before <group_wait> has expired, eg "10"
# max_retry:          # Number of attempts to relay messages to plugins in case of error
# timeout:            # Time to wait for response from the plugin before considering the attempt a failure, eg "10s"

#-------------------------
# plugin-specific options

# The following template receives a list of models.Alert objects
# The output goes in the http request body
format: |
  {{ range . -}}
  {{ $alert := . -}}
  {
    "extras": {
      "client::display": {
      "contentType": "text/markdown"
    }
  },
  "priority": 3,
  {{range .Decisions -}}
  "title": "{{.Type }} {{ .Value }} for {{.Duration}}",
  "message": "{{.Scenario}}  \n\n[crowdsec cti](https://app.crowdsec.net/cti/{{.Value -}})  \n\n[shodan](https://shodan.io/host/{{.Value -}})"
  {{end -}}
  }
  {{ end -}}

# The plugin will make requests to this url, eg:  https://www.example.com/
url: https://<GOTFIY_URL>/message

# Any of the http verbs: "POST", "GET", "PUT"...
method: POST

headers:
  X-Gotify-Key: <GOTIFY_API_KEY>
  Content-Type: application/json
# skip_tls_verification:  # true or false. Default is false
```

https://doc.crowdsec.net/docs/notification_plugins/http/

https://doc.crowdsec.net/docs/notification_plugins/gotify