KLP_CONVERT := $(realpath ../../klp-convert)

TEST_SUFFIX := -klp-convert
OUTDIR_PREFIX := /tmp/klp-convert

# List of klp-convert enabled kernel selftest .ko's
KOBJS := \
  test_klp_convert1.ko \
  test_klp_convert2.ko \
  test_klp_convert_data.ko \
  test_klp_convert_keys.ko \
  test_klp_convert_sections.ko

ARCHES := \
  x86_64 \
  ppc64le \
  ppc32 \
  s390 \
  arm64

# Assume targets for each arch
$(foreach arch,$(ARCHES), \
    $(eval TARGETS+=$(addprefix $(arch)/, \
                    $(addsuffix $(TEST_SUFFIX), $(KOBJS)))))

# List of compressed symbols.klp files
$(foreach arch,$(ARCHES), \
    $(eval SYMBOLS_KLP+=$(addprefix $(arch)/,symbols.klp)))

all: $(TARGETS)
$(TARGETS): $(SYMBOLS_KLP) klp-convert

%.klp: %.klp.gz
	gunzip --force --keep $<

# Cached .ko filenames omit ".ko" filename extension to dodge kbuild's
# make clean destruction.
%.tmp.ko: %.tmp.gz
	gunzip --force --keep $< --stdout > $@
%.ko: %.gz
	gunzip --force --keep $< --stdout > $@

klp-convert:
	test -x "$(KLP_CONVERT)" || \
	  (echo "Can't find klp-convert executable" && false)

%.ko$(TEST_SUFFIX): %.tmp.ko %.ko
	$(KLP_CONVERT) $(dir $@)symbols.klp $< $@
	diff $@ $(subst $(TEST_SUFFIX),,$@)
	@echo PASS $(basename $@)

update:
	$(foreach arch,$(ARCHES), \
	    mkdir -p $(arch); \
	    gzip --stdout --keep $(OUTDIR_PREFIX)-$(arch)/symbols.klp > $(arch)/symbols.klp.gz; \
	    $(foreach kobj,$(KOBJS), \
	        gzip --stdout --keep $(OUTDIR_PREFIX)-$(arch)/lib/livepatch/$(kobj) > $(arch)/$(subst .ko,.gz,$(kobj)); \
	        gzip --stdout --keep $(OUTDIR_PREFIX)-$(arch)/lib/livepatch/$(subst .ko,.tmp.ko,$(kobj)) > $(arch)/$(subst .ko,.tmp.gz,$(kobj)); ))

clean:
	$(RM) $(SYMBOLS_KLP) $(TARGETS)

.PHONY: all klp-convert clean
