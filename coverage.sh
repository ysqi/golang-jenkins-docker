#!/bin/bash
#
# Generate test coverage statistics for Go packages.
#
# 原脚本地址：https://github.com/appleboy/golang-testing/blob/master/coverage.sh

set -e

output() {
  color="32"
  if [[ "$2" -gt 0 ]]; then
    color="31"
  fi
  printf "\033[${color}m"
  echo $1
  printf "\033[0m"
} 

workdir=".cover"
cover_mode="set"
kernel_name=$(uname -s)
 
# 获取所包含的项目包
packages=$(go list ./... | grep -v vendor)
 
# add this function on your .bashrc file to echoed Go version
go_version() {
  if [ "$1" = "" ]; then
    match=1
  else
    match=2
  fi
  version=$(go version)
  regex="go(([0-9].[0-9]).[0-9])"
  if [[ $version =~ $regex ]]; then
    echo ${BASH_REMATCH[${match}]}
  fi
}

set_workdir() {
  workdir=$1
  test -d $workdir || mkdir -p $workdir
  coverage_report="$workdir/coverage.txt"
  coverage_xml_report="$workdir/coverage.xml"
  junit_report="$workdir/junit.txt"
  junit_xml_report="$workdir/report.xml"
  lint_report="$workdir/lint.txt"
  vet_report="$workdir/vet.txt"
  cloc_report="$workdir/cloc.xml"
}

install_dependency_tool() {
  goversion=$(go_version "gloabl")
  [ -d "${GOPATH}/bin" ] || mkdir -p ${GOPATH}/bin
  go get -u github.com/jstemmer/go-junit-report
  go get -u github.com/axw/gocov/gocov
  go get -u github.com/AlekSi/gocov-xml 
  go get -u github.com/golang/lint/golint 

  curl https://raw.githubusercontent.com/AlDanial/cloc/master/cloc -o ${GOPATH}/bin/cloc
  chmod 755 ${GOPATH}/bin/cloc
}

errorNumber() {
  if [ "$1" -ne 0 ]; then
    error=$1
  fi
}

testing() {
  error=0
  test -f ${junit_report} && rm -f ${junit_report}
  output "Running ${cover_mode} mode for coverage."
  for pkg in $packages; do
    f="$workdir/$(echo $pkg | tr / -).cover"
    output "Testing coverage report for ${pkg}"
    go test -v -cover -coverprofile=${f} -covermode=${cover_mode} $pkg | tee -a ${junit_report}
    # ref: http://stackoverflow.com/questions/1221833/bash-pipe-output-and-capture-exit-status
    errorNumber ${PIPESTATUS[0]}
  done

  output "Convert all packages coverage report to $coverage_report"
  echo "mode: $cover_mode" > "$coverage_report"
  grep -h -v "^mode:" "$workdir"/*.cover >> "$coverage_report"
  if [ "$error" -ne 0 ]; then
    output "Get Tesing Error Number Code: ${error}" ${error}
  fi
}

generate_cover_report() {
  gocov convert ${coverage_report} | gocov-xml > ${coverage_xml_report}
}

generate_junit_report() {
  cat ${junit_report} | go-junit-report > ${junit_xml_report}
}

generate_lint_report() {
  for pkg in $packages; do
    output "Go Lint report for ${pkg}"
    golint ${pkg} | tee -a ${lint_report}
  done

  # fix path error
  root_path=${PWD//\//\\/}
  [ "$kernel_name" == "Darwin" ] && sed -e "s/${root_path}\(\/\)*//g" -i '' ${lint_report}
  [ "$kernel_name" == "Linux" ] && sed -e "s/${root_path}\(\/\)*//g" -i ${lint_report}
}

generate_vet_report() {
  for pkg in $packages; do
    output "Go Vet report for ${pkg}"
    go vet -n -x ${pkg}
    go vet -n -x ${pkg} | tee -a ${vet_report}
  done
}

generate_cloc_report() {
  cloc --by-file --xml --out=${cloc_report} --exclude-dir=vendor,Godeps,.cover .
}


# 设置工作目录
set_workdir $workdir
# 1.安装依赖工具
# output "installing tool..."
# install_dependency_tool
# output "installing tool completed"
# 2.测试， 如果测试失败则终止
testing
# 生成报告
# 3.1
generate_cover_report
# 3.2
generate_junit_report
# 3.3
generate_lint_report
# 3.4
generate_vet_report
# 3.5
generate_cloc_report


if [[ "$error" -gt 0 ]]; then
  exit $error
fi

