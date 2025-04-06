use rama_client::*;

fn main() {
    let client = Client::new("http://localhost:8080".to_string()).unwrap();
    println!("Result: {:?}", client);
}
