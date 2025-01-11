package main

import (
	"fmt"
)

func main() {
	// Create a map with a key of type string and value of type int
	m := make(map[string]int)

	// Add key-value pairs to the map
	m["k1"] = 7
	m["k2"] = 13

	fmt.Println("map:", m)

	// Access a value by key
	v1 := m["k1"]
	fmt.Println("v1: ", v1)

	// Get the length of the map
	fmt.Println("len:", len(m))

	// Remove a key-value pair from the map
	delete(m, "k2")
	fmt.Println("map:", m)

	// Check if a key is present in the map
	_, prs := m["k2"]
	fmt.Println("prs:", prs)

	// Declare and initialize a map in one line
	n := map[string]int{"foo": 1, "bar": 2}
	fmt.Println("map:", n)
}
