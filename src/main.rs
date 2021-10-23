use std::fs;
use std::path::Path;

fn main() {
    // using compile time env we declare where the assets are installed in.
    //  this path is used to create the full absolute filename of helloworld.txt
    let contents = fs::read_to_string(
        Path::new(option_env!("SHAREDIR").unwrap_or(".")).join("helloworld.txt"),
    )
    .expect("Something went wrong reading the file");
    // message reads "Hello, world!" as is tradition.
    println!("{}", contents);

    // use os_info crate to detect operating system and print out OS information
    //  it is able to gather.
    let info = os_info::get();
    println!("OS information: {}", info);
}

// eof
