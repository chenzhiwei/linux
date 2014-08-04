# laravel

一个为Web艺术家创建的PHP框架。

A PHP framework for web artisans.

## Install PHP module

```
$ sudo apt-get install php5-cli php5-mcrypt php5-json php5-curl
$ sudo php5enmod mcrypt
$ sudo php5enmod json
$ sudo php5enmod curl
```

## Install PHP composer

Dependency Manager for PHP.

其实就是PHP生态系统的安装包管理工具，用来下载各种PHP相关的包。

```
$ mkdir ~/.bin
$ curl -sS https://getcomposer.org/installer | php -- --install-dir=~/.bin --filename=composer
```

## Checkout laravel code and install dependency

```
# mkdir -p /var/www/html
# cd /var/www/html
# git clone https://github.com/laravel/laravel 
# cd /var/www/html/laravel
# php ~/.bin/composer install
```

## Configure laravel

```
# cd /var/www/html/laravel
# chmod -R 777 app/storage
# vim bootstrap/start.php
# mkdir -p app/config/local
# vim app/config/local/app.php
# vim app/config/local/cache.php
# vim app/config/local/database.php
# mv server.php index.php
```

* bootstrap/start.php

code snippet

```php
$env = $app->detectEnvironment(array(
    'local' => array('ubuntu'),
));
```

以上代码的意思是让laravel自动检测你的当前环境。

local 为环境名称，是本地的意思。 ubuntu 就是你本地机器的机器名（hostname）。

* app/config/local/app.php

```php
<?php
return array(
    'debug' => true,
);

```

以上意思是开启本地调试功能。

* app/config/local/cache.php

```php
<?php

return array(
    'driver' => 'file',
);
```

以上意思是本地使用文件缓存系统。

* app/config/local/database.php

```php
<?php
return array(
    'default' => 'mysql',
    'connections' => array(
        'mysql' => array(
            'driver'    => 'mysql',
            'host'      => '127.0.0.1',
            'database'  => 'db_name',
            'username'  => 'db_user',
            'password'  => 'db_pass',
            'charset'   => 'utf8',
            'collation' => 'utf8_unicode_ci',
            'prefix'    => '',
        ),
    ),
);
```

以上意思是本地使用MySQL数据库，当然你也可以使用其他类型数据库。

## PHP Web Runtime

Linux + Apache + MySQL + PHP

Linux + Nginx + Mysql + PHP(FPM)

随便你怎么配，记住运行根目录是`/var/www/html/laravel`。

## Pretty URLs

Apache::.htaccess

```
Options +FollowSymLinks
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
```

Nginx

```
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## 创建数据表

如下几步是创建表的操作，表结构可以在migrate文件中定义。

```
# cd /var/www/html/laravel
# php artisan migrate:install
# php artisan migrate:make create_tags_table
# vim app/database/migrations/2014_07_26_010703_create_tags_table.php
# php artisan migrate
```

* app/database/migrations/2014_07_26_010703_create_tags_table.php

```php
<?php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
class CreateTagsTable extends Migration {
    public function up()
    {
        Schema::table('tags', function($t) {
            $t->create();
            $t->increments('id');
            $t->string('name');
            $t->string('slug');
        });
    }
    public function down()
    {
        Schema::drop('tags');
    }
}
```

## Namespace

如果想自定义自己的MVC存放位置，可以使用命名空间的方式。

```
<?php
use path/to/Articles

class ArticleController extends BaseController
{
    // you can call Articles class here.
}
```

需要在`composer.json`里添加如下内容

```
"autoload" : {
  "psr-0" : {
    "path\\" : "app/"
  }
}
```

然后执行

```
$ composer dump-autoload
```

## 题外话

Laravel 把很多东西都封装起来了，主要的麻烦是学习这个框架的过程，因为它很复杂。

## The End

好了，接下来你可以开始用laravel来做相应的开发了。
