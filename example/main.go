package main

import (
	"io/ioutil"
	"fmt"

	// "github.com/golang/example/stringutil"
)

func main(){
	var notGood = "not good"
	_=notGood

	var n= note() 
	fmt.Println(n) 
}

func reverse(src string) string{
	return ""
	// return stringutil.Reverse(src)
}
func note() string{
	if false {
		fmt.Println("nerver")
	}
	return "Today is nice day!"
}

func bad() {
	fmt.Sprintf("is %s or %s","bad")
}

func bad2(){
	var s1 string = "S1"
	s1 = s1 // 自赋值
}

func bad3(){
	f,_:=ioutil.TempFile("","bad")
	defer f.Close()
}