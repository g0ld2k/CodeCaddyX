# CodeCaddyX

## Description
CodeCaddyX has the ability to take code selections and send them to ChatGTP from within Xcode to perform various actions including:
* Code Explanation
* Create function/class documentation
* Generate Unit Tests
* Perform Code Review

Based on the actions being performed the changes will occur inline within the current Xcode document open (in the case of generating documentation) or display analytical content in the companion app (code explanations, unit tests, code reviews, etc.).

## Installation

Download and install the latest version from [CodeCaddyX Releases Page](https://github.com/g0ld2k/CodeCaddyX/tags)

### Configuring

#### Enable the Extension

1. Open up the *System Settings* App
2. Click on *Privacy & Security*
3. Click on *Extensions*
4. Click on *Xcode Source Editor*
5. Check the box next to *CodeCaddyX*
6. Tap on *Done*

### Enter your API key

1. Launch *CodeCaddyX* app
2. Tap on the *Settings* tab
3. Enter your OpenAI API key
4. Tap on *Save*

## Architecture
![Unknown](https://user-images.githubusercontent.com/3504814/233398220-321b9514-2880-498c-a092-1a42d76c8e81.png)

## See it in Action

A dummy struct was created with some problems, let's see what CodeCaddy can do:
```swift
import Foundation

struct Foo {
    func add(numA: Int, num2: Int) -> Int {
        return numA + num2
    }

    func subtract(letter: Int, number: Int) -> Int {
        return letter + number
    }

    func doSomething(str: String?) -> String {
        if let str {
            return String(str.reversed())

        }

        return ""
    }
}
```

### Code Explanation

<img width="1235" alt="Explination" src="https://user-images.githubusercontent.com/3504814/233398921-8abdb519-b4b6-4801-a7a9-05772138e9b1.png">

### Create function/class documenation
<img width="852" alt="Documentation" src="https://user-images.githubusercontent.com/3504814/233399147-f684a773-efd9-4583-97dc-6caf46502955.png">

### Unit Tests
<img width="1232" alt="Unit Tests" src="https://user-images.githubusercontent.com/3504814/233399327-43a70803-31fa-48e9-b336-aad6c98edd81.png">

### Code Review

<img width="1232" alt="Code Review" src="https://user-images.githubusercontent.com/3504814/233399487-d70b563c-f164-4d06-9ad3-3f13e0a6617d.png">


