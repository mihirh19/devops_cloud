package main

import (
	"fmt"
)

type Geometry interface {
	area() float64
	perim() float64
}

type rect struct {
	width, height float64
}

func (r rect) area() float64 {
	return r.width * r.height
}

func (r rect) perim() float64 {
	return 2*r.width + 2*r.height
}

func main() {

	fmt.Println("interface:")
	var g Geometry = rect{width: 10, height: 5}
	fmt.Println(g)
	fmt.Println(g.area())
	fmt.Println(g.perim())

}
