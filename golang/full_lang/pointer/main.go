package main

import "fmt"

func main() {

	// Declare a pointer to an int
	var p *int

	// Declare an int
	i := 42

	// Assign the address of i to p
	p = &i

	// Read i through the pointer p
	fmt.Println(*p) // 42

	// Set the value of i through the pointer p
	*p = 21

	// Read the new value of i
	fmt.Println(i) // 21
}
