# Elide API

Elide provides API for users to interact with the app:

* Public/Private API to create Elink

## Create Elink
URL: http://elid.me/api/v1/elinks

Method: POST

Headers:
```
Authorization: <token>
Content-Type: application/json
```

Payload:
```
{
  "urls": [<url1>, <url2>, ...]
  "domain": <domain|optional>
}
```

For anonymous access you can use `open-access` in Authorization header
or you can generate the token after sign up. `open-access` token can only
be used 100 times per hour from one IP address. Users generated token has higher threshold.

### Examples:
1. Calling API with anonymous token and the default domain:

```
POST /api/v1/elinks HTTP/1.1
Accept: application/json
Accept-Encoding: gzip, deflate
Authorization: open-access
Connection: keep-alive
Content-Length: 38
Content-Type: application/json
Host: elid.me

{
    "urls": [
        "http://google.com"
    ]
}

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 47
content-type: application/json; charset=utf-8
date: Mon, 22 Feb 2016 15:52:00 GMT
server: Cowboy

{
    "id": "lYfo",
    "short_url": "elid.me/lYfo"
}
```

2. Calling API with user token and specific domain

```
POST /api/v1/elinks HTTP/1.1
Accept: application/json
Accept-Encoding: gzip, deflate
Authorization: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJpZCI6M30.dwAFBwAGzWFlNvBI3qXZ0Jlpb4muYThk4QAiAoVItN0
Connection: keep-alive
Content-Length: 70
Content-Type: application/json
Host: elid.me

{
    "domain": "elid.me",
    "urls": [
        "http://google.com", "http://github.com"
    ]
}

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 47
content-type: application/json; charset=utf-8
date: Mon, 22 Feb 2016 15:56:01 GMT
server: Cowboy

{
    "id": "mZfp",
    "short_url": "elid.me/mZfp"
}
```
