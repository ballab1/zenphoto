location @zenphoto {

    # experimental rss rules
    rewrite ^/index\.php\?^rss-(.*)&(.*)    /index.php?rss=$1 last;
    rewrite ^/index\.php\?^rss-(.*)$        /index.php?rss=$1 last;

    rewrite ^/index\.php$ /index.php last;
    rewrite ^/(.*)/page/([A-Za-z0-9_\-]+)/?$ /index.php?album=$1&page=$2 last;

    # Images and stuff
    rewrite "^/(.*)/image/(thumb|[0-9]{1,4})/([^/\\\]+)$"  /zp-core/i.php?a=$1&i=$3&s=$2  last;
    rewrite ^/(.*)/image/([^/\\\]+)$  /zp-core/i.php?a=$1&i=$2  last;
    rewrite "^/(.*)/album/(thumb|[0-9]{1,4})/([^/\\\]+)$"  /zp-core/i.php?a=$1&i=$3&s=$2&album=true  last;

    # Catch all for unknown stuff
    rewrite ^/(.*)/?$ /index.php?album=$1 last;
}

location @albums {
     rewrite ^/albums/?(.+/?)?$  /$1  redirect;
}

# Admin pages
location /admin {
    rewrite ^/admin/?$ /zp-core/admin.php redirect;
}

location /albums {
    try_files $uri @albums;
}

# Tiny URLs
location /tiny {
    rewrite ^/tiny/([0-9]+)/?$ /index.php?p=$1&t last;
}

# Page
location /page {
    rewrite ^/page/([0-9]+)/?$ /index.php?page=$1 last;
    rewrite ^/page/([A-Za-z0-9\-_]+)/?$ /index.php?p=$1 last;
    rewrite ^/page/([A-Za-z0-9_\-]+)/([0-9]+)/?$ /index.php?p=$1&page=$2 last;
}

# Pages
location /pages {
    rewrite ^/pages/?$ /index.php?p=pages last;
    rewrite ^/pages/(.*)/?$ /index.php?p=pages&title=$1 last;
}

# Search
location /page/search {
    rewrite ^/page/search/fields([0-9]+)/(.*)/([0-9]+)/?$ /index.php?p=search&searchfields=$1&words=$2&page=$3 last;
    rewrite ^/page/search/fields([0-9]+)/(.*)/?$ /index.php?p=search&searchfields=$1&words=$2 last;
    rewrite ^/page/search/archive/(.*)/([0-9]+)/?$ /index.php?p=search&date=$1&page=$2 last;
    rewrite ^/page/search/archive/(.*)/?$ /index.php?p=search&date=$1 last;
    rewrite ^/page/search/tags/(.*)/([0-9]+)/?$ /index.php?p=search&searchfields=tags&words=$1&page=$2 last;
    rewrite ^/page/search/tags/(.*)/?$ /index.php?p=search&searchfields=tags&words=$1 last;
    rewrite ^/page/search/(.*)/([0-9]+)/?$ /index.php?p=search&words=$1&page=$2 last;
    rewrite ^/page/search/(.*)/?$ /index.php?p=search&words=$1 last;
}

# News
location /news {
    rewrite ^/news/?$ /index.php?p=news last;
    rewrite ^/news/([0-9]+)/?$ /index.php?p=news&page=$1 last;
    rewrite ^/news/category/(.*)/([0-9]+)/?$ /index.php?p=news&category=$1&page=$2 last;
    rewrite ^/news/category/(.*)/?$ /index.php?p=news&category=$1 last;
    rewrite ^/news/archive/(.*)/([0-9]+)/?$ /index.php?p=news&date=$1&page=$2 last;
    rewrite ^/news/archive/(.*)/?$ /index.php?p=news&date=$1 last;
    rewrite ^/news/(.*)/?$ /index.php?p=news&title=$1 last;
}

location / {
    try_files $uri $uri/ @zenphoto;
}
