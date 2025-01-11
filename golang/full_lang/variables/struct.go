package variables

import "fmt"

type person struct {
	name string
	age  int
}

func main() {
	var p1 person
	p1.name = "John"
	p1.age = 25

	fmt.Println(p1)

	p2 := person{name: "Jane", age: 30}
	fmt.Println(p2)

	p3 := person{"Doe", 35}
	fmt.Println(p3)
}
