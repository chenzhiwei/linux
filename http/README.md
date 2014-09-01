# HTTP

HTTP是HyperText Transport Protocol的缩写，意思是超文本传输协议，是互联网上使用最广泛的协议。大学毕业做毕业设计时记录过一些关于HTTP协议的内容，所以做了一些简单的记录。

## HTTP协议的请求方法

HTTP协议的请求方法有GET、HEAD、POST、PUT、DELETE、TRACE、CONNECT。

GET方法意为获取Request-URI标识的所有信息，Request-URI可以简单的理解为浏览器地址栏中域名后面的那部分内容。

HEAD方法与GET方法非常相似，只获取由Request-URI所标识的资源的响应消息报头。

POST方法是在Request-URI所标识的资源后附加新的数据。

PUT方法是请求服务器存储一个资源，并用Request-URI作为其标识。

DELETE方法是请求服务器删除Request-URI所标识的资源。

TRACE方法是请求服务器回送收到的请求信息，主要用于测试或诊断。

CONNECT方法是保留方法，将来使用。

注：HTTP/1.0只有三个请求方法，即GET、HEAD、POST。其他几个方法是HTTP/1.1新加上去的。

HTTP/1.0的请求方法文档：<http://www.w3.org/Protocols/HTTP/1.0/spec.html#Method>

HTTP/1.1的请求方法文档：<http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.1>

## WebDAV协议的请求方法

WebDAV是Web Distributed Authoring and Versioning的缩写，可以认为是HTTP协议的扩展，WebDAV将HTTP从一个只读的协议变成了一个可以读写的协议。

WebDAV的方法比较多，有PROPFIND、PROPPATCH、MKCOL、COPY、MOVE、LOCK、UNLOCK等方法。具体解释这里就不多说了，可以参考WebDAV的文档：<http://www.webdav.org/specs/rfc4918.html>

## HTTP协议的状态码

### Information 1xx

临时响应，表示临时响应并需要请求者继续执行操作的状态代码。

**100 Continue** 继续，表示请求者应当继续提出请求，服务器返回此代码表示已收到请求的第一部分，正在等待其余部分。

**101 Switching Protocols** 切换协议，表示请求者已要求服务器切换协议，服务器已确认并准备切换。

### Successful 2xx

成功，表示客户端的请求被成功接收、理解并接受了。

**200 OK** 成功，表示服务器已成功处理了请求。通常，这表示服务器提供了请求的网页。

**201 Created** 已创建，表示请求成功并且服务器创建了新的资源。

**202 Accepted** 已接收，表示服务器已接受请求，但尚未处理。

**203 Non-Authoritative Information** 非授权信息，表示服务器已成功处理了请求，但返回的信息可能来自另一来源。

**204 No Content** 无内容，表示服务器成功处理了请求，但没有返回任何内容。

**205 Reset Content** 重置内容，表示服务器成功处理了请求，但没有返回任何内容。

**206 Partial Content** 部分内容，表示服务器成功处理了部分GET请求。

### Redirection 3xx

重定向，表示要完成请求，需要进一步操作。通常，这些状态代码用来重定向。

**300 Multiple Choices** 多种选择，表示针对请求，服务器可执行多种操作。服务器可根据请求者(user agent)选择一项操作，或提供操作列表供请求者选择。

**301 Moved Permanently** 永久移动，表示请求的网页已永久移动到新位置。服务器返回此响应（对GET或HEAD请求的响应）时，会自动将请求者转到新位置。

**302 Found** 临时移动，表示服务器目前从不同位置的网页响应请求，但请求者应继续使用原有位置来进行以后的请求（这个302是HTTP/1.0里的状态码，但是描述的不够清楚，所以HTTP/1.1就添加了303和307来加以区分）。

**303 See Other** 查看其他位置，也算临时移动，比如客户端发过来的是POST/PUT/DELETE请求，服务端已经收到了发过来的数据，那么需要客户端再向定向后的地址发送一个GET请求就可以了。这个和307有点区别，通常大部分浏览器都将302当成303来处理了。

**304 Not Modified** 未修改，表示自从上次请求后，请求的网页未修改过。服务器返回此响应时，不会返回网页内容。

**305 Use Proxy** 使用代理，表示请求者只能使用代理访问请求的网页。如果服务器返回此响应，还表示请求者应使用代理。

**306 (Unused)** 未使用的状态码，留给以后的版本使用。

**307 Temporary Redirect** 临时重定向，表示服务器目前从不同位置的网页响应请求，但请求者应继续使用原有位置来进行以后的请求。如果客户端发过来的是POST/PUT/DELETE请求，那么需要客户端重新带上POST/PUT/DELETE的数据再发一次。

注：当发送来的是GET请求时，302/303/307是一样的，仅当发送POST/PUT/DELETE请求时才会有区别。

### Client Error 4xx

4xx系列状态码表示客户端请求可能出错，妨碍了服务器的处理。

**400 Bad Request** 错误请求，表示服务器不理解请求的语法。

**401 Unauthorized** 未授权，表示请求要求身份验证。对于需要登录的网页，服务器可能返回此响应。

**402 Payment Required** 需要支付了，具体的不清楚。

**403 Forbidden** 禁止，表示服务器拒绝请求。

**404 Not Found** 未找到，表示服务器找不到请求的网页。

**405 Method Not Allowed** 方法禁用，表示禁用请求中指定的方法。

**406 Not Acceptable** 不接受，表示无法使用请求的内容特性响应请求的网页。

**407 Proxy Authentication Required** 需要代理授权，此状态代码与401未授权类似，但指定请求者应当授权使用代理。

**408 Request Timeout** 请求超时，表示服务器等候请求时发生超时。

**409 Conflict** 冲突，表示服务器在完成请求时发生冲突。服务器必须在响应中包含有关冲突的信息。

**410 Gone** 已删除，如果请求的资源已永久删除，服务器就会返回此响应。

**411 Length Required** 需要有效的长度，表示服务器不接受不含有效内容长度标头字段的请求。

**412 Precondition Failed** 未满足前提条件，表示服务器未满足请求者在请求中设置的其中一个前提条件。

**413 Request Entity Too Large** 请求实体过大，表示服务器无法处理请求，因为请求实体过大，超出服务器的处理能力。

**414 Request-URI Too Long** 请求的URI过长，表示请求的 URI（通常为网址）过长，服务器无法处理。

**415 Unsupported Media Type** 不支持的媒体类型，表示请求的格式不受请求页面的支持。

**416 Requested Range Not Satisfiable** 请求范围不符合要求，表示如果页面无法提供请求的范围，则服务器会返回此状态代码。

**417 Expectation Failed** 未满足期望值，服务器未满足“期望”请求标头字段的要求。

### Server Error 5xx

5xx系列状态代码表示服务器在尝试处理请求时发生内部错误。这些错误可能是服务器本身的错误，而不是请求出错。

**500 Internal Server Error** 服务器内部错误，表示服务器遇到错误，无法完成请求。

**501 Not Implemented** 尚未实施，表示服务器不具备完成请求的功能。例如，服务器无法识别请求方法时可能会返回此代码。

**502 Bad Gateway** 网关错误，表示服务器作为网关或代理，从上游服务器收到无效响应。

**503 Service Unavailable** 服务不可用，表示服务器目前无法使用（由于超载或停机维护）。通常，这只是暂时状态。

**504 Gateway Timeout** 网关超时，表示服务器作为网关或代理，但是没有及时从上游服务器收到请求。

**505 HTTP Version Not Supported** 不支持的HTTP版本，表示服务器不支持请求中所用的 HTTP 协议版本。

## HTTP Header其他域

有好多东西，改天再写上来。

## Reference

1. HTTP/1.0的响应状态码文档： <http://www.w3.org/Protocols/HTTP/1.0/spec.html#Status-Codes>

2. HTTP/1.1的响应状态码文档： <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>

3. HTTP响应码介绍： <http://en.wikipedia.org/wiki/List_of_HTTP_status_codes>

4. HTTP协议详解（中文），很经典： <http://www.cnblogs.com/li0803/archive/2008/11/03/1324746.html>

5. HTTP反向代理： <http://en.wikipedia.org/wiki/Reverse_proxy>

6. HTTP代理与反向代理： <http://stackoverflow.com/questions/224664/difference-between-proxy-server-and-reverse-proxy-server>
