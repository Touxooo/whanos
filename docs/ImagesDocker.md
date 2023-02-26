# How work whanos images

## Summary

1. Which images exist
2. Types of images
3. How to use it

### 1. Which images exist

You have 8 images for 8 different languages:

- C
- C++
- Go
- Rust
- Befunge
- Java
- Javascript
- Python

### 2. Types of images

Two different types of Whanos images have to be created for each language, corresponding to two different types of use.

- Standalone images

    Applications that do not need to configure their runtime environment further than the default configuration above will use standalone images.

    These images must allow for the application to run smoothly without external modification.

    Such applications will have no Dockerfile at the root of their repository.

- Base images

    Some applications will need to configure their runtime environment further than the default configuration described above, but they will still be based on Whanos images; as such, they will be based on another type of image: the base images.

    These images must set the environment up just like the standalone images, but you have to keep in mind that they will be referenced by the FROM instruction of a custom Dockerfile.


### 3. How to use it

For each languages you have condition to use them with a whanos images

- C - Go

    You must have a Makefile file at the root of your repository and your binary must be named by “compiled-app”

- C++

    You must have a CMakeList.txt file at the root of your repository and you binary must be named by “compiled-app”

- Rust

    You must have a Cargo.toml file at the root of your repository and your binary must be named by “compiled-app”

- Befunge

    You must to have a "app" directory at the root of your repository with a file named “main.bf” inside

- Java

    You must have a “app” directory at the root of your repository with a “pom.xml” file inside

- Javascript

    You must have a package.json at the root of your repository

- Python

    You must have a “requirements.txt” file at the root of your repository