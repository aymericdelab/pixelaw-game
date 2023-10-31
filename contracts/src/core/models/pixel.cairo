use starknet::{ContractAddress, ClassHash};

#[derive(Copy, Drop, Serde, Introspect)]
struct Position {
    x: u64,
    y: u64
}


#[derive(Copy, Drop, Serde, Introspect)]
struct Color {
    r: u8,
    g: u8,
    b: u8
}

#[derive(Copy, Drop, Serde)]
struct PixelUpdate {
    position: Position,
    color: Option<Color>,
    owner: Option<ContractAddress>,
    app: Option<ContractAddress>,
    text: Option<felt252>,
    timestamp: Option<u64>,
    alert: Option<felt252>
}

#[derive(Model, Copy, Drop, Serde)]
struct Pixel {
    #[key]
    position: Position,
    color: Color,
    owner: ContractAddress,
    app: ContractAddress,
    text: felt252,
    timestamp: u64,
    alert: felt252
}

