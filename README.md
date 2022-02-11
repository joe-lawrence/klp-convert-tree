# klp-convert-tree

Kernel tree for development of the klp-convert build tool.

## Branches and Commit Message Conventions

| Branch                      | Description                         |
| ----------------------------|-------------------------------------|
| **klp-convert-vX**          | suitable for upstream kernel review |
| **klp-convert-vX-devel**    | on-going development and testing    |

**klp-convert-vX-devel** branches contain additional commits:

* Expanded git history contains follow up fixes, prefixed by "(squash)" in subject lines.  These will be squashed when cherry picked to the   **klp-convert-vX** branches, creating a curated branch suitable for upstream review.

* klp-convert development helpers (Makefiles, unit tests, etc.) introduced in commits prefixed by "(devel)".  These commits only facilitate development and will be omitted from the **klp-convert-vX** branches.

* May be periodically rebased and force pushed.


Building and Testing
--------------------

Both **klp-convert-vX** and **klp-convert-vX-devel** branches may be built as an ordinary kernel tree.

The **klp-convert-vX-devel** branches add a few development helpers to the tree:

### scripts/livepatch/Makefile.devel

**Makefile.devel** is a standalone version of the kbuild Makefile in the same directory.  This allows for building klp-convert directly:
```
  # From top level kernel directory
  $ make -C scripts/livepatch/ -f Makefile.devel

  # From scripts/livepatch/
  $ make -f Makefile.devel
```
### scripts/livepatch/tests
The **tests/** subdirectory is still its formative stage.  At the moment, it consists of cached copies of kernel livepatching selftests that exercise klp-convert.  Intermediate .ko files and symbols.klp are passed through klp-convert and compared with expected finalized .ko files.  These may be run with **Makefile.devel**'s tests target:
```
  # From top level kernel directory
  $ make -C scripts/livepatch/ -sf Makefile.devel tests

  # From scripts/livepatch/
  $ make -sf Makefile.devel tests
```
### cross-dev
The **cross-dev** wrapper script invokes cross compilers to build the kernel for non-native arches.  With default **.cross-dev** settings, it leverages Intel's [Linux Kernel Performance tests's](https://github.com/intel/lkp-tests) **make.cross** to setup and run compiler environments.  (Other cross compilers may be used by setting up **MAKE_CROSS**, detailed below.)  The klp-convert program still builds and runs natively, but kernel build artifacts are created by specified compilers.

* Currently supported architectures: x86_64, ppc64le, ppc32, s390, arm64
* Defaults and overrides for the *configure*, *build*, and *clean* sub-commands (specified by the **.cross-dev** file):
  * **ARCHES** : By default, **cross-dev** will execute for all supported architectures. This can be overridden:  `ARCHES="x86_64 s390" ./cross-dev ...`
  * **OUTDIR_PREFIX** : Save kernel build output into per-arch output directories.  The default is **/tmp/klp-convert-\<ARCH\>**, but may be overridden:  `OUTDIR_PREFIX="./build" ./cross-dev ...`
  * **MAKE_CROSS** : Specifies the make invocation to invoke the cross compilers.  The Intel cross compilers are used by default, see the **.cross-dev** configuration file for more toolchain options.
  * **COMPILER_INSTALL_PATH** : The Intel crosstool's default installation directory is **/home/0day/**, to change:   `COMPILER_INSTALL_PATH=/tmp ./cross-dev ...`
  * **COMPILER** : Intel builds a [few compiler versions](https://download.01.org/0day-ci/cross-package/), including clang, and defaults to  **gcc-9.3.0**.  To pick a specific compiler:  `COMPILER=gcc-11.2.0 ./cross-dev ...`
  * Non-default values should be specified (repeated) for all *configure*, *build*, and *clean* sub-command invocations.

* The *configure* sub-command: setup various architecture **.config** files.  Installs the Intell cross compilers (if selected).  Kernel configuration starts with each architecture's defconfig and additional options are enabled to turn on **CONFIG_LIVEPATCH** and related features.  See the table below (following the *build* sub-command) for disk requirements.
* The *build* sub-command: run the cross-compiler for architecture(s).  An initial **-j8** build for all architectures on an [Intel(R) Core(TM) i7-8650U](https://ark.intel.com/content/www/us/en/ark/products/124968/intel-core-i78650u-processor-8m-cache-up-to-4-20-ghz.html) laptop takes about 90 minutes to complete.  The project's **make.cross** version has been modified to work with [ccache](https://ccache.dev/) to improve subsequent builds.  The following disk space is required for installation and build:

| Arch    | Toolset | Kernel Build |
|---------|---------|--------------|
| arm64   | 585M    | 2.9G         |
| ppc32   | 568M    | 560M         |
| ppc64le | 565M    | 682M         |
| s390    | 523M    | 5.2G         |
| x86_64  | 657M    | 650M         |

* The *clean* sub-command:  run `make clean` for specified architecture(s).

Typical workflow:
``` bash
./cross-dev clean
./cross-dev config
./cross-dev build -j$(nproc)

# ... edit kernel / klp-convert sources ...

./cross-dev build -j$(nproc)

# ... etc ...
# ... inspect kernel-build vmlinux, .o or .ko files ...
```
