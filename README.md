#  Jeroo: A tool for learning Object-Oriented Programming

Play now! [jeroo.org/beta](https://www.jeroo.org/beta)

More info: [jeroo.org](https://www.jeroo.org)

## What is Jeroo?

Jeroo is a text-based coding environment designed to help novices master the basic mechanics of object oriented programming. It features a limited syntax to emphasize basic computational thinking skills like problem decomposition (ie, breaking things down into subtasks), the semantics of control structures like loops and ifs, and use of objects and state to solve problems. 

## Screenshots

![](https://www.jeroo.org/images/ScreenCapture.gif)

## Resources for Teachers and Students

Our Introduction to Jeroo textbook provides an overview of how to program with Jeroo and gives more details about the system's backstory. Three different versions of the book are linked below, corresponding to the three language styles available. Pick the one that matches your target language. Note that the appendix materials showing screenshots of Jeroo are based on the stand-alone program, rather than the new web-based Jeroo--they're still a work in progress. 

## The Team

- Ben Konz
- Caelan Bryan
- Thomas Connole
- John Adam
- Brian Dorn

The best way to contact us with questions, comments or feature requests, is to email support@jeroo.org.

## Building from source

Build tools:
- yarn
- opam (m4 required by opam)

### Building the compiler

Opam is experimental on Windows, so I would stick to
MacOS or Linux to build the compiler. Once the JerooCompiler.bc.js 
has been created, any platform can build the rest of the site.

```text
cd src/compiler
opam switch create ./ ocaml-base-compiler.4.08.1
opam install --deps-only .
eval $(opam env)
dune build ./JerooCompiler.bc.js --profile release
dune runtest # optional, verify all compiler tests pass
```

The compiler JavaScript is located in `jeroo/src/compiler/_build/default/JerooCompiler.bc.js`

### Building the frontend

```text
# cd to project root
yarn install
yarn build --prod
yarn test # optional, run unit tests
yarn e2e # optional, run end-to-end tests (only works on Firefox)
```

The newly built site is located in `jeroo/dist/jeroo`