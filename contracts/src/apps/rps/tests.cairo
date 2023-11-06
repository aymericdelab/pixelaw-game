// use starknet::{ContractAddressIntoFelt252, contract_address_const};

// use starknet::{ContractAddress, syscalls::deploy_syscall};
// use starknet::class_hash::{ClassHash, Felt252TryIntoClassHash};
// use dojo::database::query::{IntoPartitioned, IntoPartitionedQuery};
// use dojo::interfaces::{
//     IComponentLibraryDispatcher, IComponentDispatcherTrait, ISystemLibraryDispatcher,
//     ISystemDispatcherTrait
// };
// use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// use dojo::test_utils::spawn_test_world;

// use pixelaw::components::position::Position;
// use pixelaw::rps::components::game::{game, Game};
// use pixelaw::rps::systems::create::create;
// use pixelaw::rps::systems::commit::commit;

// use pixelaw::rps::utils::hash_commit;

// use pixelaw::rps::tests::create::create_game;

// fn player_commit(world: IWorldDispatcher, game_id: u32, hash: felt252, position: Position) {
//     let mut player_commit_calldata = array::ArrayTrait::<felt252>::new();
//     player_commit_calldata.append(game_id.into());
//     player_commit_calldata.append(hash);

//     // serialize position
//     position.serialize(ref player_commit_calldata);

//     world.execute('commit'.into(), player_commit_calldata.span());
// }

// fn player_reveal(
//     world: IWorldDispatcher,
//     game_id: u32,
//     hash: felt252,
//     commit: u8,
//     salt: felt252,
//     position: Position
// ) {
//     let mut player_commit_calldata = array::ArrayTrait::<felt252>::new();
//     player_commit_calldata.append(game_id.into());
//     player_commit_calldata.append(hash);
//     player_commit_calldata.append(commit.into());
//     player_commit_calldata.append(salt);

//     // serialize position
//     position.serialize(ref player_commit_calldata);

//     world.execute('reveal'.into(), player_commit_calldata.span());
// }

#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use pixelaw::core::models::registry::{
        Registry, app_by_system, app_by_name, core_actions_address
    };

    use pixelaw::core::models::pixel::{Pixel, PixelUpdate};
    use pixelaw::core::models::pixel::{pixel};
    use pixelaw::core::models::permissions::{permissions};
    use pixelaw::core::utils::{Direction, Position, DefaultParameters};
    use pixelaw::core::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};

    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use pixelaw::apps::rps::app::{
        rps_actions, game, player, IRpsActionsDispatcher, IRpsActionsDispatcherTrait
    };
    use pixelaw::apps::rps::app::{Game, Player};
    use pixelaw::apps::rps::app::{
        STATE_CREATED, STATE_JOINED, STATE_FINISHED, ROCK, PAPER, SCISSORS
    };


    use zeroable::Zeroable;

    fn deploy_world() -> (IWorldDispatcher, IActionsDispatcher, IRpsActionsDispatcher) {
        // Deploy World and models
        let world = spawn_test_world(
            array![
                pixel::TEST_CLASS_HASH,
                game::TEST_CLASS_HASH,
                player::TEST_CLASS_HASH,
                app_by_system::TEST_CLASS_HASH,
                app_by_name::TEST_CLASS_HASH,
                core_actions_address::TEST_CLASS_HASH,
                permissions::TEST_CLASS_HASH,
            ]
        );

        // Deploy Core actions
        let core_actions = IActionsDispatcher {
            contract_address: world
                .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap())
        };

        // Deploy RPS actions
        let rps_actions = IRpsActionsDispatcher {
            contract_address: world
                .deploy_contract('salt', rps_actions::TEST_CLASS_HASH.try_into().unwrap())
        };
        (world, core_actions, rps_actions)
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_playthrough() {
        // Deploy everything
        let (world, core_actions, rps_actions) = deploy_world();

        core_actions.init();
        rps_actions.init();

        // Impersonate player1
        let player1 = starknet::contract_address_const::<0x1337>();
        let player2 = starknet::contract_address_const::<0x42>();
        starknet::testing::set_contract_address(player1);

        // Set the players commitments
        let player1_commit: u8 = SCISSORS;
        let player2_commit: u8 = PAPER;

        // Set the player's secret salt. For the test its just different, client will send truly random
        let player1_salt = '1';
        let player1_hash: felt252 = hash_commit(player1_commit, player1_salt.into());

        // Player 1 submits their hashed commit
        rps_actions
            .interact(
                DefaultParameters {
                    for_player: Zeroable::zero(),
                    for_system: Zeroable::zero(),
                    position: Position { x: 1, y: 1 },
                    color: 0
                },
                player1_hash
            );

        // Player 1 submits their hashed commit
        rps_actions
            .interact(
                DefaultParameters {
                    for_player: Zeroable::zero(),
                    for_system: Zeroable::zero(),
                    position: Position { x: 1, y: 1 },
                    color: 0
                },
                player1_hash
            );

        // TODO assert state

        starknet::testing::set_contract_address(player2);
        // Player2 joins
        rps_actions
            .join(
                DefaultParameters {
                    for_player: Zeroable::zero(),
                    for_system: Zeroable::zero(),
                    position: Position { x: 1, y: 1 },
                    color: 0
                },
                player2_commit
            );

        starknet::testing::set_contract_address(player1);
        // Player2 joins
        rps_actions
            .finish(
                DefaultParameters {
                    for_player: Zeroable::zero(),
                    for_system: Zeroable::zero(),
                    position: Position { x: 1, y: 1 },
                    color: 0
                },
                player1_commit,
                player1_salt
            );
    }
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use poseidon::poseidon_hash_span;

    // TODO: implement proper psuedo random number generator
    fn random(seed: felt252, min: u128, max: u128) -> u128 {
        let seed: u256 = seed.into();
        let range = max - min;

        (seed.low % range) + min
    }

    fn hash_commit(commit: u8, salt: felt252) -> felt252 {
        let mut hash_span = ArrayTrait::<felt252>::new();
        hash_span.append(commit.into());
        hash_span.append(salt.into());

        poseidon_hash_span(hash_span.span())
    }
}
