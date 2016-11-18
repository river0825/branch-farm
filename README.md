# Branch Farm

在開發的過程中簡易的在 client 的網址列指定要執行的 branch

nginx 在接收到訊息時，會將 branch 的 code clone 下來，並啟動對應的 docker

nginx 用 rewrite 的方式將 request 導至指定的 docker port

## usage


### specific the branch you want
add param from get uri

```
http://yourcompany.com?__branch__=develop
```

it will also create a cookie to remember the last branch you use.

### clear the setting

delete the cookie "__branch__" in browser


