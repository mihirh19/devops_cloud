package main

import (
	"fmt"
)

func main() {
	var x int

	fmt.Scan(&x)
	fmt.Println(x)
	if x > 5 {
		fmt.Println("x is greater than 5")
	}

}
