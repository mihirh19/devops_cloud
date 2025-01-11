package main

import (
	"fmt"
)

func main() {
	// Create a channel
	ch := make(chan string)

	// Send a value to the channel
	go func() {
		ch <- "Hello, World!"
	}()

	// Receive a value from the channel
	msg := <-ch
	fmt.Println(msg)

	// Close the channel
	close(ch)

	// Send a value to the closed channel
	go func() {
		ch <- "Hello, World!"
	}()

	// Receive a value from the closed channel
	msg = <-ch
	fmt.Println(msg)

	// Send a value to the closed channel
	go func() {
		ch <- "Hello, World!"
	}()

	// Receive a value from the closed channel
	msg = <-ch
	fmt.Println(msg)
}
