# DNS

## Anycast

## 注意事项

根据[RFC 1034][rfc-1034] 文档说明，当DNS查询一个域名非CNAME记录外的其他记录时，如果本地DNS缓存里存在了该域名的CNAME记录，那么就直接用该域名CNAME记录去继续查找。所以最好不要给一个域名同时设置CNAME和MX记录。

比如`chenzhiwei.cn`的CNAME指向了`jizhihuwai.com`，MX记录指向了`mx.jizhihuwai.com`：

```
chenzhiwei.cn CNAME jizhihuwai.com
chenzhiwei.cn MX mx.jizhihuwai.com
```

当你先查询`chenzhiwei.cn`的CNAME记录时，DNS会缓存下来`jizhihuwai.com`。再次查询MX记录时，DNS会直接用缓存下来的`jizhihuwai.com`来继续查找MX记录，这样一来`chenzhiwei.cn`的MX记录就变成`jizhihuwai.com`的MX记录了。。。

[rfc-1034]: https://tools.ietf.org/html/rfc1034
