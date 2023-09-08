#[system]
mod process_queue_system {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;
    use pixelaw::events::{Event, QueueFinished};

    fn execute(
        ctx: Context,
        id: usize,
        unlock: u64,
        execution: felt252,
        arguments: Array<felt252>
    ) {
        assert(unlock <= starknet::get_block_timestamp(), 'unlock time not passed');
        ctx.world.execute(execution, arguments);
        emit!(ctx.world, Event::QueueFinished(QueueFinished { id }));
    }
}