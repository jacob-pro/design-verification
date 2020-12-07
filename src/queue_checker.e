<'
import driver;

struct queue_checker_s {

    add_sub_queue: list of pending_task_s;
    shift_queue: list of pending_task_s;

    start_with(running_tasks: list of pending_task_s) is {
        for each pending_task_s (p) in running_tasks {
            if (p.ins.cmd_in == opcode_t'ADD.as_a(uint) || p.ins.cmd_in == opcode_t'SUB.as_a(uint)) {
                add_sub_queue.add(p);
            };
            if (p.ins.cmd_in == opcode_t'SHL.as_a(uint) || p.ins.cmd_in == opcode_t'SHR.as_a(uint)) {
                shift_queue.add(p);
            };
        };

    };

    check_update(new_running_tasks: list of pending_task_s) is {

        // Find which tasks are being removed on this update
        var add_sub_queue_removals: list of pending_task_s;
        var shift_queue_removals: list of pending_task_s;
        for each pending_task_s (p) in add_sub_queue {
            if (new_running_tasks.first_index(it == p) == UNDEF) {
                add_sub_queue_removals.add(p);
            };
        };
        for each pending_task_s (p) in shift_queue {
            if (new_running_tasks.first_index(it == p) == UNDEF) {
                shift_queue_removals.add(p);
            };
        };

        // For each ADD/SUB task being removed,
        for each pending_task_s (p) in add_sub_queue_removals {
            var queue_position: int = add_sub_queue.first_index(it == p);
            assert queue_position != UNDEF;
            // check it is either at the front of the queue
            // or that the item in front of it is also being removed on the same cycle / same time
            if (queue_position != 0) {
                check that (add_sub_queue_removals.first_index(it == add_sub_queue[queue_position - 1]) != UNDEF) else
                    dut_errorf("An ADD/SUB operation completed ahead of an earlier operation");
            };
            add_sub_queue.delete(queue_position);
        };

        // For each SHIFT task being removed,
        for each pending_task_s (p) in shift_queue_removals {
            var queue_position: int = shift_queue.first_index(it == p);
            assert queue_position != UNDEF;
            // check it is either at the front of the queue
            // or that the item in front of it is also being removed on the same cycle / same time
            if (queue_position != 0) {
                check that (shift_queue_removals.first_index(it == shift_queue[queue_position - 1]) != UNDEF) else
                    dut_errorf("A SHIFT operation completed ahead of an earlier operation");
            };
            shift_queue.delete(queue_position);
        };

        // Add new tasks to the queues
        for each pending_task_s (p) in new_running_tasks {
            if (p.ins.cmd_in == opcode_t'ADD.as_a(uint) || p.ins.cmd_in == opcode_t'SUB.as_a(uint)) {
                if (add_sub_queue.first_index(it == p) == UNDEF) {
                    add_sub_queue.add(p);   // Add to end of queue
                };
            };
            if (p.ins.cmd_in == opcode_t'SHL.as_a(uint) || p.ins.cmd_in == opcode_t'SHR.as_a(uint)) {
                if (shift_queue.first_index(it == p) == UNDEF) {
                    shift_queue.add(p);   // Add to end of queue
                };
            };
        };
    };

};

'>
