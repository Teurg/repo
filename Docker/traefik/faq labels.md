
Включает Traefik для данного контейнера.

```
"traefik.enable=true"
```

Определяет точку входа для маршрутизатора `traefik` по протоколу HTTP.

```
"traefik.http.routers.traefik.entrypoints=http"
```

Устанавливает правило для маршрутизатора `traefik`, которое указывает, что данный маршрутизатор должен обрабатывать запросы к хосту `traefik.name.ru`.

```
"traefik.http.routers.traefik.rule=Host(`traefik.name.ru`)"
```

Настраивает Middleware `traefik-auth` для базовой аутентификации с пользователем `Hrust` и паролем `password`.

```
"traefik.http.middlewares.traefik-auth.basicauth.users=Hrust:"
```

Настраивает Middleware для перенаправления HTTP-запросов на HTTPS.

```
"traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
```

Добавляет заголовок `X-Forwarded-Proto=https` к запросам.
\
```
"traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
```

Связывает Middleware `traefik-https-redirect` с маршрутизатором `traefik`.

```
"traefik.http.routers.traefik.middlewares=traefik-https-redirect"
```

Определяет точку входа для маршрутизатора `traefik-secure` по протоколу HTTPS.

```
"traefik.http.routers.traefik-secure.entrypoints=https"
```

Устанавливает правило для маршрутизатора `traefik-secure`, которое указывает, что данный маршрутизатор должен обрабатывать запросы к хосту `traefik.name.ru`.

```
"traefik.http.routers.traefik-secure.rule=Host(`traefik.name.ru`)"
```

Связывает Middleware `traefik-auth` с маршрутизатором `traefik-secure`.

```
"traefik.http.routers.traefik-secure.middlewares=traefik-auth"
```

Включает TLS для маршрутизатора `traefik-secure`.

```
"traefik.http.routers.traefik-secure.tls=true"
```

Указывает, что для маршрутизатора `traefik-secure` будет использоваться сертификат, полученный через `certresolver` под именем `cloudflare`.

```
"traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
```

Устанавливает основной домен `name.ru` для TLS-сертификата.

```
"traefik.http.routers.traefik-secure.tls.domains[0].main=damain.ru"
```

Устанавливает дополнительные SAN (Subject Alternative Name) для TLS-сертификата, включающие все поддомены `*.name.ru`.

```
"traefik.http.routers.traefik-secure.tls.domains[0].sans=*.domain.ru"
```

Устанавливает сервис для маршрутизатора `traefik-secure` на `api@internal`, который является внутренним API Traefik.

```
"traefik.http.routers.traefik-secure.service=api@internal"
```


