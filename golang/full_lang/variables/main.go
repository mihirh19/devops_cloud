package variables

import (
	"fmt"
)

func main() {
	var a int = 1
	var (
		b int = 2
		c int = 3
	)

	const d int = 4
	fmt.Println(a, b, c)
	fmt.Println(d)
}
