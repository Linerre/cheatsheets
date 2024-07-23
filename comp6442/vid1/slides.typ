#import "@preview/touying:0.3.3": *

#let s = themes.university.register(aspect-ratio: "16-9")
// Presenter information
#let s = (s.methods.info)(
    self: s,
    title: [Out of Box],
    subtitle: [Compile and run your Java programs out of Intellij IDEA],
    date: [2024-03-22],
    author: [Zhiren Lin u7753813\@aun.edu.au]
)

#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init


#let (slide, empty-slide) = utils.slides(s)
#show: slides.with(slide-level: 1)

== Using feature-rich Intellij IDEA
#slide[
    #figure(
        image("intellij.png", width: 90%),
    )
]

== Using Command line

#slide[
    On Linux/macOS:

    ```shell
      javac // compiler
      java
    ```

    On Windows:
    ```shell
      javac.exe
      java.exe
    ```
]

== Quick Facts

#slide[
    - The `javac` command reads _source files_

    - Source files conventionally placed under a directory (folder) called `src`

    - A source file has the file extension `.java`
        - `Location.java`
        - `User.java`

    - A source file's name is the same as the *class* defined in it
        - `Location.java` defines `Loacation` class
        ```java
        // Location.java file
        public class Location implements Subject<User> {
            // definition details
        }
        ```
]


= Compile

== Compile `.java` files

#slide[
    Using `javac` commands:
    ```shell
      javac Location.java
    ```

    And #pause we got those `.class` files, for example:
    - `Location.class`
    - `AttendanceLog.class`

    Also #pause the current directory becomes a bit messy ...
    ```shell
    $ ls
      AttendanceLog.java AttendanceLog.class Location.java  LocationTest.class ...

    ```
]


== Better options

#slide[
    Using `-d` options:
    ```shell
      javac -d compile Location.java AttendanceLog.java ...
    ```

    Using `@filename` option
    ```shell
      javac -d compile @filename
    ```

]

= Run

== Run `.java` files
#slide[
    Using the `java` command:
    ```shell
    java Location.class
    ```

    #pause
    However, usually we need a `main` method ...
    But we don't have it in this case.

    We will run our tests in `LocationTest.class` only
]


== `-classpath` option
#slide[

    #pause
    Specifying where to search for more/other `.class` files

    #pause
    #show raw.where(block: false): box.with(
        fill: luma(240),
        inset: 4pt,
    )
    Using `:` to separate paths
    ```shell
      -classpath path1:path2:path3
     ```

    #pause
    Even shorter `-cp`
    ```shell
      -cp path1:path2:path3
     ```

]

== Resources
#slide[
    #show link: underline
    - The `javac` Command
    #link("https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html")

    - The `java` Command
    #link("https://docs.oracle.com/en/java/javase/17/docs/specs/man/java.html")
]
