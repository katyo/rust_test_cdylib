extern crate libloading;

use libloading::Library;
use std::env::args;

fn main() {
    let path = args()
        .next()
        .unwrap()
        .replace("test_cdylib", "libtest_cdylib.so");

    let _ = Library::new(path).unwrap();

    println!("plugins loaded");
}
