FROM golang

MAINTAINER ysqi <devysq@gmail.com>

# 安装工具
RUN apt-get -y update && apt-get install -y zip 
# 下载Go文件 
# 国内无法访问goole库资源，需要从github上下载后移动到指定目录。
# 当然可以使用 git clone --depth=1 https://github.com/golang/tools.git $GOPATH/src/golang.org/x/tools 代替，但是没有下载zip包快。
RUN wget https://github.com/golang/tools/archive/master.zip -O /tmp/tools.zip
RUN mkdir -p $GOPATH/src/golang.org/x/ \ 
    && cd $GOPATH/src/golang.org/x \
    && unzip -o  /tmp/tools.zip "tools-master/*"  \ 
    && mv -f tools-master tools \
    && ls -all 

RUN go get  github.com/jstemmer/go-junit-report
RUN go get  github.com/axw/gocov/gocov
RUN go get  github.com/AlekSi/gocov-xml
RUN go get  github.com/golang/lint/golint
RUN go get  github.com/mitchellh/gox
# a markdown processor for Go
RUN go get -u github.com/russross/blackfriday-tool
# install govendor tool
RUN go get -u github.com/kardianos/govendor
# install embedmd tool
RUN go get -u github.com/campoy/embedmd

# install cloc tool
RUN curl https://raw.githubusercontent.com/AlDanial/cloc/master/cloc -o /usr/bin/cloc \
  && chmod 755 /usr/bin/cloc

ADD coverage.sh /usr/bin/coverage
COPY coverage.sh /app/coverage.sh
RUN chmod +x /app/coverage.sh

WORKDIR $GOPATH

ENTRYPOINT  /app/coverage.sh