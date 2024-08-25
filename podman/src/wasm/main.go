// GOOS=wasip1 GOARCH=wasm go build -o main.wasm main.go
package main

import "fmt"

func main() {
	fmt.Println("Hello, WebAssembly!")
}
