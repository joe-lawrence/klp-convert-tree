#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022 Joe Lawrence <joe.lawrence@redhat.com>

. $(dirname $0)/functions.sh

MOD_LIVEPATCH=test_klp_livepatch
MOD_KLP_CONVERT_MOD=test_klp_convert_mod
MOD_KLP_CONVERT1=test_klp_convert1
MOD_KLP_CONVERT2=test_klp_convert2
MOD_KLP_CONVERT_DATA=test_klp_convert_data
MOD_KLP_CONVERT_KEYS_MOD=test_klp_convert_keys_mod
MOD_KLP_CONVERT_KEYS=test_klp_convert_keys

setup_config


# TEST: klp-convert symbols (late module patching, relocation clearing)
# - load a livepatch that modifies the output from /proc/cmdline
#   including a reference to vmlinux-local symbol that klp-convert
#   will process
# - load target module
# - unload target module
# -- kernel clears klp-relocations in livepatch
# - load targer module
# - verify correct behavior
# - unload the livepatch

start_test "klp-convert symbols (late module patching, relocation clearing)"

saved_cmdline=$(cat /proc/cmdline)

load_lp $MOD_KLP_CONVERT1
load_mod $MOD_KLP_CONVERT_MOD
unload_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT1/parameters/print_debug
load_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT1/parameters/print_debug
disable_lp $MOD_KLP_CONVERT1
unload_lp $MOD_KLP_CONVERT1
unload_mod $MOD_KLP_CONVERT_MOD

load_lp $MOD_KLP_CONVERT2
load_mod $MOD_KLP_CONVERT_MOD
unload_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT2/parameters/print_debug
load_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT2/parameters/print_debug
disable_lp $MOD_KLP_CONVERT2
unload_lp $MOD_KLP_CONVERT2
unload_mod $MOD_KLP_CONVERT_MOD

check_result "% modprobe $MOD_KLP_CONVERT1
livepatch: enabling patch '$MOD_KLP_CONVERT1'
livepatch: '$MOD_KLP_CONVERT1': initializing patching transition
livepatch: '$MOD_KLP_CONVERT1': starting patching transition
livepatch: '$MOD_KLP_CONVERT1': completing patching transition
livepatch: '$MOD_KLP_CONVERT1': patching complete
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT1' to loading module '$MOD_KLP_CONVERT_MOD'
% rmmod $MOD_KLP_CONVERT_MOD
livepatch: reverting patch '$MOD_KLP_CONVERT1' on unloading module '$MOD_KLP_CONVERT_MOD'
$MOD_KLP_CONVERT1: saved_command_line, 0: $saved_cmdline
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT1' to loading module '$MOD_KLP_CONVERT_MOD'
$MOD_KLP_CONVERT1: saved_command_line, 0: $saved_cmdline
$MOD_KLP_CONVERT1: driver_name, 0: $MOD_KLP_CONVERT_MOD
$MOD_KLP_CONVERT1: test_klp_get_driver_name(), 0: $MOD_KLP_CONVERT_MOD
$MOD_KLP_CONVERT1: homonym_string, 1: homonym string A
$MOD_KLP_CONVERT1: get_homonym_string(), 1: homonym string A
test_klp_convert1: klp_string.12345: lib/livepatch/test_klp_convert_mod_a.c static string
test_klp_convert1: klp_string.67890: lib/livepatch/test_klp_convert_mod_b.c static string
% echo 0 > /sys/kernel/livepatch/$MOD_KLP_CONVERT1/enabled
livepatch: '$MOD_KLP_CONVERT1': initializing unpatching transition
livepatch: '$MOD_KLP_CONVERT1': starting unpatching transition
livepatch: '$MOD_KLP_CONVERT1': completing unpatching transition
livepatch: '$MOD_KLP_CONVERT1': unpatching complete
% rmmod $MOD_KLP_CONVERT1
% rmmod $MOD_KLP_CONVERT_MOD
% modprobe $MOD_KLP_CONVERT2
livepatch: enabling patch '$MOD_KLP_CONVERT2'
livepatch: '$MOD_KLP_CONVERT2': initializing patching transition
livepatch: '$MOD_KLP_CONVERT2': starting patching transition
livepatch: '$MOD_KLP_CONVERT2': completing patching transition
livepatch: '$MOD_KLP_CONVERT2': patching complete
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT2' to loading module '$MOD_KLP_CONVERT_MOD'
% rmmod $MOD_KLP_CONVERT_MOD
livepatch: reverting patch '$MOD_KLP_CONVERT2' on unloading module '$MOD_KLP_CONVERT_MOD'
$MOD_KLP_CONVERT2: saved_command_line (auto): $saved_cmdline
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT2' to loading module '$MOD_KLP_CONVERT_MOD'
$MOD_KLP_CONVERT2: saved_command_line (auto): $saved_cmdline
$MOD_KLP_CONVERT2: driver_name, 0: $MOD_KLP_CONVERT_MOD
$MOD_KLP_CONVERT2: test_klp_get_driver_name(), (auto): $MOD_KLP_CONVERT_MOD
$MOD_KLP_CONVERT2: homonym_string, 2: homonym string B
$MOD_KLP_CONVERT2: get_homonym_string(), 2: homonym string B
% echo 0 > /sys/kernel/livepatch/$MOD_KLP_CONVERT2/enabled
livepatch: '$MOD_KLP_CONVERT2': initializing unpatching transition
livepatch: '$MOD_KLP_CONVERT2': starting unpatching transition
livepatch: '$MOD_KLP_CONVERT2': completing unpatching transition
livepatch: '$MOD_KLP_CONVERT2': unpatching complete
% rmmod $MOD_KLP_CONVERT2
% rmmod $MOD_KLP_CONVERT_MOD"


# TEST: klp-convert data relocations (late module patching, relocation clearing)

start_test "klp-convert data relocations (late module patching, relocation clearing)"

load_lp $MOD_KLP_CONVERT_DATA
load_mod $MOD_KLP_CONVERT_MOD
unload_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT_DATA/parameters/print_debug
load_mod $MOD_KLP_CONVERT_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT_DATA/parameters/print_debug
disable_lp $MOD_KLP_CONVERT_DATA
unload_lp $MOD_KLP_CONVERT_DATA
unload_mod $MOD_KLP_CONVERT_MOD

check_result "% modprobe $MOD_KLP_CONVERT_DATA
livepatch: enabling patch '$MOD_KLP_CONVERT_DATA'
livepatch: '$MOD_KLP_CONVERT_DATA': initializing patching transition
livepatch: '$MOD_KLP_CONVERT_DATA': starting patching transition
livepatch: '$MOD_KLP_CONVERT_DATA': completing patching transition
livepatch: '$MOD_KLP_CONVERT_DATA': patching complete
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT_DATA' to loading module '$MOD_KLP_CONVERT_MOD'
% rmmod $MOD_KLP_CONVERT_MOD
livepatch: reverting patch '$MOD_KLP_CONVERT_DATA' on unloading module '$MOD_KLP_CONVERT_MOD'
% modprobe $MOD_KLP_CONVERT_MOD
livepatch: applying patch '$MOD_KLP_CONVERT_DATA' to loading module '$MOD_KLP_CONVERT_MOD'
$MOD_KLP_CONVERT_DATA: local_small: 1111
$MOD_KLP_CONVERT_DATA: const_local_small: 2222
$MOD_KLP_CONVERT_DATA: static_local_small: 3333
$MOD_KLP_CONVERT_DATA: static_const_local_small: 4444
$MOD_KLP_CONVERT_DATA: local_large[0..3]: 1111 2222 3333 4444
$MOD_KLP_CONVERT_DATA: const_local_large[0..3]: 5555 6666 7777 8888
$MOD_KLP_CONVERT_DATA: static_local_large[0..3]: 9999 aaaa bbbb cccc
$MOD_KLP_CONVERT_DATA: static_const_local_large[0..3]: dddd eeee ffff 0
$MOD_KLP_CONVERT_DATA: global_small: 1111
$MOD_KLP_CONVERT_DATA: const_global_small: 2222
$MOD_KLP_CONVERT_DATA: static_small: 3333
$MOD_KLP_CONVERT_DATA: static_const_small: 4444
$MOD_KLP_CONVERT_DATA: global_large[0..3]: 1111 2222 3333 4444
$MOD_KLP_CONVERT_DATA: const_global_large[0..3]: 5555 6666 7777 8888
$MOD_KLP_CONVERT_DATA: static_large[0..3]: 9999 aaaa bbbb cccc
$MOD_KLP_CONVERT_DATA: static_const_large[0..3]: dddd eeee ffff 0
$MOD_KLP_CONVERT_DATA: static_read_mostly: 2222
% echo 0 > /sys/kernel/livepatch/$MOD_KLP_CONVERT_DATA/enabled
livepatch: '$MOD_KLP_CONVERT_DATA': initializing unpatching transition
livepatch: '$MOD_KLP_CONVERT_DATA': starting unpatching transition
livepatch: '$MOD_KLP_CONVERT_DATA': completing unpatching transition
livepatch: '$MOD_KLP_CONVERT_DATA': unpatching complete
% rmmod $MOD_KLP_CONVERT_DATA
% rmmod $MOD_KLP_CONVERT_MOD"


# TEST: klp-convert static keys (late module patching, relocation clearing)
# - load a module which defines static keys, updates one of the keys on
#   load (forcing jump table patching)
# - load a livepatch that references the same keys, resolved by
#   klp-convert tool
# - poke the livepatch sysfs interface to update one of the key (forcing
#   jump table patching again)
# - disable and unload the livepatch
# - remove the module

start_test "klp-convert static keys (late module patching, relocation clearing)"

load_lp $MOD_KLP_CONVERT_KEYS
load_mod $MOD_KLP_CONVERT_KEYS_MOD
unload_mod $MOD_KLP_CONVERT_KEYS_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT_KEYS/parameters/print_debug
load_mod $MOD_KLP_CONVERT_KEYS_MOD
echo 1 > /sys/module/$MOD_KLP_CONVERT_KEYS/parameters/enable_false_key
disable_lp $MOD_KLP_CONVERT_KEYS
unload_lp $MOD_KLP_CONVERT_KEYS
unload_mod $MOD_KLP_CONVERT_KEYS_MOD

check_result "% modprobe $MOD_KLP_CONVERT_KEYS
livepatch: enabling patch '$MOD_KLP_CONVERT_KEYS'
livepatch: '$MOD_KLP_CONVERT_KEYS': initializing patching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': starting patching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': completing patching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': patching complete
% modprobe $MOD_KLP_CONVERT_KEYS_MOD
livepatch: applying patch '$MOD_KLP_CONVERT_KEYS' to loading module '$MOD_KLP_CONVERT_KEYS_MOD'
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: initial conditions
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is true
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is true
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: disabled test_klp_true_key
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is false
% rmmod $MOD_KLP_CONVERT_KEYS_MOD
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: unloading conditions
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is false
livepatch: reverting patch '$MOD_KLP_CONVERT_KEYS' on unloading module '$MOD_KLP_CONVERT_KEYS_MOD'
$MOD_KLP_CONVERT_KEYS: print_key_status: print_debug_set
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&tracepoint_printk_key) is false
$MOD_KLP_CONVERT_KEYS: static_branch_unlikely(&tracepoint_printk_key) is false
% modprobe $MOD_KLP_CONVERT_KEYS_MOD
livepatch: applying patch '$MOD_KLP_CONVERT_KEYS' to loading module '$MOD_KLP_CONVERT_KEYS_MOD'
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: initial conditions
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is true
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is true
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: disabled test_klp_true_key
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS: print_key_status: set_enable_false_key start
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&tracepoint_printk_key) is false
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&test_klp_false_key) is false
$MOD_KLP_CONVERT_KEYS: static_branch_unlikely(&tracepoint_printk_key) is false
$MOD_KLP_CONVERT_KEYS: print_key_status: set_enable_false_key enabling test_klp_false_key
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&tracepoint_printk_key) is false
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS: static_key_enabled(&test_klp_false_key) is true
$MOD_KLP_CONVERT_KEYS: static_branch_unlikely(&tracepoint_printk_key) is false
% echo 0 > /sys/kernel/livepatch/$MOD_KLP_CONVERT_KEYS/enabled
livepatch: '$MOD_KLP_CONVERT_KEYS': initializing unpatching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': starting unpatching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': completing unpatching transition
livepatch: '$MOD_KLP_CONVERT_KEYS': unpatching complete
% rmmod $MOD_KLP_CONVERT_KEYS
% rmmod $MOD_KLP_CONVERT_KEYS_MOD
$MOD_KLP_CONVERT_KEYS_MOD: print_key_status: unloading conditions
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_key_enabled(&test_klp_false_key) is true
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_likely(&test_klp_true_key) is false
$MOD_KLP_CONVERT_KEYS_MOD: static_branch_unlikely(&test_klp_false_key) is true"


exit 0
