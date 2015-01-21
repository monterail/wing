# Wing

Convert github markdown with mermaid diagrams to beautiful PDF

## Requirements
- PhantomJS

## Installation

```bash
gem install wing
```

## Usage

### Creating new project

```bash
mkdir my-doc
cd my-doc
wing init
```

### Generating PDF

```bash
wing gen
```

## Embedding diagrams

    ```diagram
    graph LR
        A[Square Rect] -- Link text --> B((Circle))
        A --> C(Round Rect)
        B --> D{Rhombus}
        C --> D
    ```



## Contributing

1. Fork it ( https://github.com/monterail/wing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
