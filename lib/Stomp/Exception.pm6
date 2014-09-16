class Stomp::Exception is Exception {
    has Str $.message;

    method gist() { $.message  }
}
