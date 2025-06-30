use axum::{
    routing::get,
    Router,
    extract::Path,
    response::Json,
};
use solana_client::rpc_client::RpcClient;
use serde_json::{json, Value};

async fn get_balance(Path(wallet_address): Path<String>) -> Json<Value> {
    let rpc_url = "https://api.devnet.solana.com"; // Devnet
    let client = RpcClient::new(rpc_url);
    
    match client.get_balance(&wallet_address.parse().unwrap()) {
        Ok(balance) => Json(json!({
            "wallet": wallet_address,
            "balance": balance,
            "lamports": balance,
            "sol": balance as f64 / 1_000_000_000.0
        })),
        Err(e) => Json(json!({
            "error": e.to_string()
        }))
    }
}
// Replace the main function with this:
#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/balance/:wallet_address", get(get_balance));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Server running on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}