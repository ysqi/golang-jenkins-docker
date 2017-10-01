
# Docker - gotestreport

基于[Go Testing](https://github.com/appleboy/golang-testing)修改，以方便GFW下正常运行。

所实现的测试分析内容：
+ go test <br>测试结果转换为junit.xml 文件 
+ go tool cover<br>覆盖率存放为xml和HTML格式，可参考 Golang'blog [cover story](https://blog.golang.org/cover)
+ go tool vet <br> 代码规范检查 
+ [golint](https://github.com/golang/lint) <br> 代码规范检查
+ [cloc](https://github.com/AlDanial/cloc)  <br> 代码覆盖率测试

## 安装
Docker官方[查看](https://cloud.docker.com/swarm/ysqi/repository/docker/ysqi/gotestreport)
```shell
docker pull ysqi/gotestreport
```

## 运行
运行时，需要明确指定 workdir ，否则将对$GOPATH下所有项目进行分析。

**方法一**：记得指定运行目录
```shell
docker run -w /go/src/github.com/ysqi/com ysqi/gotestreport
```
`-w`是对应的Docker内部的文件路径，$GOPATH=/go，故完整路径为 $GOPATH/src/github.com/ysqi/com

**方法二**：映射本机目录进行分析

docker run 的参数`-v` ,可以进行关系映射。
> -v, <br>
> --volume list                    Bind mount a volume <br>
> --volume-driver string           Optional volume driver for the container <br>
> --volumes-from list              Mount volumes from the specified container(s) 
预先设置将本机路径    
```shell 
export src=$HOME/goproject/ysqi/com
export target=/go/src/github.com/ysqi/com
```
运行Docker
```shell
docker run -v $src:$target -w $target ysqi/gotestreport
```