ARG NGINX_FROM_IMAGE=nginx:mainline
FROM ${NGINX_FROM_IMAGE} 

USER root

COPY ./modules /modules/
RUN rm /etc/nginx/conf.d/default.conf
COPY ./forward.conf /etc/nginx/conf.d/forward.conf

RUN set -ex \
    && apt update \
    && apt install -y --no-install-suggests --no-install-recommends \
                patch make wget mercurial devscripts debhelper dpkg-dev \
                quilt lsb-release build-essential libxml2-utils xsltproc \
                equivs git g++ libparse-recdescent-perl libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev

WORKDIR /tmp

RUN wget http://nginx.org/download/nginx-1.25.3.tar.gz && tar -xzvf nginx-1.25.3.tar.gz
WORKDIR /tmp/nginx-1.25.3/

RUN patch -p1 < /modules/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch
RUN ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules \
--conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp \ 
--http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \ 
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module \ 
--with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module \
--with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module \ 
--with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module \ 
--with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module \
--add-module=/modules/ngx_http_proxy_connect_module

RUN make && make install