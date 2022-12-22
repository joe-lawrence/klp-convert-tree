// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2021 Joe Lawrence <joe.lawrence@redhat.com>

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/cache.h>
#include <linux/livepatch.h>
#include "test_klp_convert.h"

/* Small global */
int *p_global_small = &global_small;

/* Small global (const) */
// .rela.data.rel.ro, .rela.rodata supported ???:
int * const p_const_global_small = &const_global_small;

/* Small file-static */
static int *p_static_small = &static_small;

/* Small file-static (constant) */
static int * const p_static_const_small = &static_const_small;

/* Large global */
int *p_global_large[4] = {
	&global_large[0], &global_large[1],
	&global_large[2], &global_large[3],
};

/* Large global (const) */
// .rela.data.rel.ro, .rela.rodata supported ???:
int * const p_const_global_large[4] = {
	&const_global_large[0], &const_global_large[1],
	&const_global_large[2], &const_global_large[3],
};

/* Large file-static global */
static int *p_static_large[4] = {
	&static_large[0], &static_large[1],
	&static_large[2], &static_large[3],
};

/* Large file-static (const) */
static int * const p_static_const_large[4] = {
	&static_const_large[0], &static_const_large[1],
	&static_const_large[2], &static_const_large[3],
};

// .rela.data.rel.ro, .rela.rodata supported ???:
// static int * __ro_after_init p_static_ro_after_init = &static_ro_after_init;
static int * __read_mostly p_static_read_mostly = &static_read_mostly;

/*
 * Wrappers to verify non-zero klp-relocation int pointers.  Direct
 * null-check would result in the compiler warning about symbol addresses
 * always evaluating as true.
 */
static void print_int(const char *label, void *ptr)
{
	if (ptr)
		pr_info("%s: %x\n", label, *(int *) ptr);
}

static void print_int4(const char *label, void *ptr1, void *ptr2,
			 void *ptr3, void *ptr4)
{
	if (ptr1 && ptr2 && ptr3 && ptr3)
		pr_info("%s: %x %x %x %x\n", label,
			*(int *) ptr1, *(int *) ptr2,
			*(int *) ptr3, *(int *) ptr4);
}

static void print_variables(void)
{
	/* Small local */
	int *p_local_small = &local_small;

	/* Small local (const) */
	int * const p_const_local_small = &const_local_small;

	/* Small static-local */
	static int *p_static_local_small = &static_local_small;

	/* Small static-local (const) */
	static int * const p_static_const_local_small = &static_const_local_small;

	/* Large local */
	int *p_local_large[4] = {
		&local_large[0], &local_large[1],
		&local_large[2], &local_large[3],
	};

	/* Large local (const) */
	int * const p_const_local_large[4] = {
		&const_local_large[0], &const_local_large[1],
		&const_local_large[2], &const_local_large[3],
	};

	/* Large static-local local */
	static int *p_static_local_large[4] = {
		&static_local_large[0], &static_local_large[1],
		&static_local_large[2], &static_local_large[3],
	};

	/* Large static-local (const) */
	static int * const p_static_const_local_large[4] = {
		&static_const_local_large[0], &static_const_local_large[1],
		&static_const_local_large[2], &static_const_local_large[3],
	};

	print_int("local_small", p_local_small);
	print_int("const_local_small", p_const_local_small);
	print_int("static_local_small", p_static_local_small);
	print_int("static_const_local_small", p_static_const_local_small);
	print_int4("local_large[0..3]",
		p_local_large[0], p_local_large[1],
		p_local_large[2], p_local_large[3]);
	print_int4("const_local_large[0..3]",
		p_const_local_large[0], p_const_local_large[1],
		p_const_local_large[2], p_const_local_large[3]);
	print_int4("static_local_large[0..3]",
		p_static_local_large[0], p_static_local_large[1],
		p_static_local_large[2], p_static_local_large[3]);
	print_int4("static_const_local_large[0..3]",
		p_static_const_local_large[0], p_static_const_local_large[1],
		p_static_const_local_large[2], p_static_const_local_large[3]);

	print_int("global_small", p_global_small);
	// .rela.data.rel.ro, .rela.rodata supported ???:
	print_int("const_global_small", p_const_global_small);
	print_int("static_small", p_static_small);
	print_int("static_const_small", p_static_const_small);
	print_int4("global_large[0..3]",
		p_global_large[0], p_global_large[1],
		p_global_large[2], p_global_large[3]);
	// .rela.data.rel.ro, .rela.rodata supported ???:
	print_int4("const_global_large[0..3]",
		p_const_global_large[0], p_const_global_large[1],
		p_const_global_large[2], p_const_global_large[3]);
	print_int4("static_large[0..3]",
		p_static_large[0], p_static_large[1],
		p_static_large[2], p_static_large[3]);
	print_int4("static_const_large[0..3]",
		p_static_const_large[0], p_static_const_large[1],
		p_static_const_large[2], p_static_const_large[3]);

	// .rela.data..ro_after_init supported ???:
	// print_int("static_ro_after_init", p_static_ro_after_init);
	print_int("static_read_mostly", p_static_read_mostly);
}

/* provide a sysfs handle to invoke debug functions */
static int print_debug;
static int print_debug_set(const char *val, const struct kernel_param *kp)
{
	print_variables();

	return 0;
}
static const struct kernel_param_ops print_debug_ops = {
	.set = print_debug_set,
	.get = param_get_int,
};
module_param_cb(print_debug, &print_debug_ops, &print_debug, 0200);
MODULE_PARM_DESC(print_debug, "print klp-convert debugging info");


static struct klp_func funcs[] = {
	{
	}, { }
};

static struct klp_object objs[] = {
	{
		/* name being NULL means vmlinux */
		.funcs = funcs,
	},
	{
		.name = "test_klp_convert_mod",
		.funcs = funcs,
	}, { }
};

static struct klp_patch patch = {
	.mod = THIS_MODULE,
	.objs = objs,
};

static int test_klp_convert_init(void)
{
	int ret;

	ret = klp_enable_patch(&patch);
	if (ret)
		return ret;

	return 0;
}

static void test_klp_convert_exit(void)
{
}

module_init(test_klp_convert_init);
module_exit(test_klp_convert_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Joe Lawrence <joe.lawrence@redhat.com>");
MODULE_DESCRIPTION("Livepatch test: klp-convert-data");
MODULE_INFO(livepatch, "Y");
