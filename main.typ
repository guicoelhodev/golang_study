#set page(paper: "a4",margin: (x: 1.5cm, y: 1.5cm))
#set heading(numbering: "1.",)
#set par(justify:true)

#show heading: set block(above: 1.5em, below: 1em)
#show grid: set block(above: 2em, below: 2em)
#show raw.where(block: true): set block(above: 2em, below: 2em)

#show raw: set text(font: "Fira Code", size:1em)
#show outline.entry.where(level:1): set block(above: 1.5em)

#outline(
  title: [Summary]
)

#pagebreak()

= What is golang?

The goals of the language and its accompanyng tools were to be expressive, efficient in both compilation and execution, and effective in writing reliable and robust programs.

It borrows and adapts good ideas from many other languages, while avoiding features that gave led to complexity and unreliable code. It's facilities for concurrency are new and efficient, and its approach to data abstraction and object-oriented programming is unusually flexible. It has automatic memory management or garbage collection.

== Go project - the motivation

The go project was borne of frustration with several software system at Google that were suffering from an explosion of complexity. As a recent high-level language, Go has the benefit of hindsight, and the basics are done well: it has garbage collection, a package system, first class functions, lexical scope, a system call interface, and immutable strings in which text is generally encoded in UTF-8. But it has comparatively few features and is unlikely to add more.

= Hello world in Go

After download the language, you need to enable dependency tracking for your code by creating a `go.mod` file, to achieve that run `go mod init` giving it the name of the module your code will be in. The name is the module's module path.

== Code example - tutor

#grid(columns: (1fr, 1fr), 
  [
    ```go
    // hello-world.go
      
    package main
    import "fmt"

    func main(){
      fmt.Println("Hello world")
    }
    ```
  ],
  [
    - Declare a main package (a package is a way to group functions, and it's made up of all the files in the same directory).

    - Import the popular fmt package, which contains functions for formatting text, including printing to the console. This package is one of the standard library packages you got when you installed Go.

    - Implement a main function to print a message to the console. A main function executes by default when you run the main package.

    - Just run `go run hello-world.go` on your terminal
  ]
)

== How to import external library?

#grid(columns: (1fr, 1fr), 
  [
```go
package main
import "fmt"

import "rsc.io/quote"

func main(){
  fmt.Println(quote.Go())
}
```
  ],
  [
   - After you add your new *package*, you need to run `go mod tidy`, this will download the download module as a requirement, as well as a go.sum file for use in authenticating the module.
  #v(0.5em)
  ```
    $ go mod tidy
    go: finding module for package rsc.io/quote
    go: found rsc.io/quote in rsc.io/quote v1.5.2
  ```
  ]
)

#pagebreak()

= Create a Go Module 

Go code is grouped into packages, and packages are grouped into modules. Your module specifies dependencies needed to run your code, including the Go version and the set of other modules it requires.

Go code is grouped into packages, and packages are grouped into modules. Your module specifies dependencies needed to run your code, including the Go ersion and the set of other modules it requires.

#grid(columns: (1.5fr,1fr), 
  [
```go
package greetings

import "fmt"

func Hello(name string) string {
  message := fmt.Sprintf("Hi, %v. Welcome!", name)
  return message
}
```
],
  [
- In Go, a function whose name starts with a capital letter can be called by a function not in the same package. *This is known in Go as an exported name*.
  ]
)

== Importing this module

After create this folder, like `example/greetings` we'll create a `example/greetings-caller`. 

1. `mkdir greetings-caller` 
2. `go mod init example/greetings-caller`, after that, create `greetings-caller/main.go`: 


#grid(columns: (1fr, 1fr), 
[
  ```go
  package main

  import (
    "example/greetings"
    "fmt"
  )

  func main() {
    message := greetings.Hello("Guilherme")

    fmt.Println(message)
  }
  ```
],
[
  If you try to run this, you got an error.

  Before run `go mod tidy` to add our package, we need to edit the `go.mod` file, because we dont publish our package yet.

  ```
  ❯ go mod edit -replace example/greetings=../greetings
  ```

  - Now our `example/greetings-caller/go.mod` should be like this:

  ```go
  replace example/greetings => ../greetings
  ```
])

== Return and handle an error


#grid(columns: (1fr, 1fr), 
  [
```go
// greetings.go
package greetings

import (
	"fmt"
	"errors"
)

func Hello(name string) (string, error) {
	if name == "" {
		return "", errors.New("empty name")
	}

	message := fmt.Sprintf(
    "Hi, %v. Welcome!", name
  )
	return message, nil
}
```
  ],
  [
```go
// main.go
package main

import(
	"fmt"
	"log"
	"example/greetings"
)

func main(){
	message, err := greetings.Hello("")

	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(message)
}

```
  ]
)

- That's common error handling in Go: return  an error as a value so the caller can check for it.

#pagebreak()

= Slices and capacity in Golang

You'll use a Go slice. *A slice is like an array, except that its size changes dynamiccaly as you add and remove items*. The slice is one of Go's most useful types.

*Capacity* is the total allocated memory slots avaliable in a slice, while *length* is how many elements are currently begin used.

```go
slice := []int{1, 2, 3}

fmt.Println("Length:", len(slice))   // 3 - elements currently used
fmt.Println("Capacity:", cap(slice)) // 3 - total available space
```

To create a slice, you have two main ways:

```go
list := []string{"A", "B"} // Normal way - ["A", "B"]

list2 := make([]string, 2) // using make() - ["", ""]
```

When you `append()` and exceed capacity, Go automatically *allocates new memory*, *copies existing elements* to new location and *updates the slice header* with the new pointer, length and capacity.

```go
list := make([]string, 0, 2)  // len=0, cap=2
list = append(list, "A")      // len=1, cap=2
list = append(list, "B")      // len=2, cap=2
list = append(list, "C")      // len=3, cap=4  <- automatic doubling!
```

When you defined a slice size, is more efficient in go.

#grid(columns: (1fr, 1fr), 
  [
```go
// Without pre-allocated slice capacity

package main
import(
	"fmt"
	"time"
)

func main() {
	start := time.Now()
	items := []int{}

	for i:=0; i< 1000000; i++ {
		items = append(items, i)
	}

	elapsed := time.Since(start)

	fmt.Println("Time taken:", elapsed)

  // Time taken: 9.826222ms
}
```
  ],
  [
```go
// With pre-allocated slice capacity

package main
import (
	"fmt"
	"time"
)

func main() {
	start := time.Now()
	items := make([]int, 0, 1000000)

	for i := 0; i < 1000000; i++ {
		items = append(items, i)
	}

	elapsed := time.Since(start)

	fmt.Println("Time taken:", elapsed)

	//Time taken: 1.827185ms
}
```
  ]
)

In the first code, Go needs to copy all existing elements into the new array, let the old array *become garbage*. Each step copies everything, perform *large memcopies* plus *allocations* and *GC pressure*. This shows up as CPU time and cache misses.

