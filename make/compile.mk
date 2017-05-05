
# create a separate list of objects per source type
MODULE_CSRCS := $(filter %.c,$(MODULE_SRCS))
MODULE_CPPSRCS := $(filter %.cpp,$(MODULE_SRCS))
MODULE_ASMSRCS := $(filter %.S,$(MODULE_SRCS))

MODULE_COBJS := $(call TOBUILDDIR,$(patsubst %.c,%.o,$(MODULE_CSRCS)))
MODULE_CPPOBJS := $(call TOBUILDDIR,$(patsubst %.cpp,%.o,$(MODULE_CPPSRCS)))
MODULE_ASMOBJS := $(call TOBUILDDIR,$(patsubst %.S,%.o,$(MODULE_ASMSRCS)))

# do the same thing for files specified in arm override mode
MODULE_ARM_CSRCS := $(filter %.c,$(MODULE_ARM_OVERRIDE_SRCS))
MODULE_ARM_CPPSRCS := $(filter %.cpp,$(MODULE_ARM_OVERRIDE_SRCS))
MODULE_ARM_ASMSRCS := $(filter %.S,$(MODULE_ARM_OVERRIDE_SRCS))

MODULE_ARM_COBJS := $(call TOBUILDDIR,$(patsubst %.c,%.o,$(MODULE_ARM_CSRCS)))
MODULE_ARM_CPPOBJS := $(call TOBUILDDIR,$(patsubst %.cpp,%.o,$(MODULE_ARM_CPPSRCS)))
MODULE_ARM_ASMOBJS := $(call TOBUILDDIR,$(patsubst %.S,%.o,$(MODULE_ARM_ASMSRCS)))

MODULE_OBJS := $(MODULE_COBJS) $(MODULE_CPPOBJS) $(MODULE_ASMOBJS) $(MODULE_ARM_COBJS) $(MODULE_ARM_CPPOBJS) $(MODULE_ARM_ASMOBJS)

#$(info MODULE_SRCS = $(MODULE_SRCS))
#$(info MODULE_CSRCS = $(MODULE_CSRCS))
#$(info MODULE_CPPSRCS = $(MODULE_CPPSRCS))
#$(info MODULE_ASMSRCS = $(MODULE_ASMSRCS))

#$(info MODULE_OBJS = $(MODULE_OBJS))
#$(info MODULE_COBJS = $(MODULE_COBJS))
#$(info MODULE_CPPOBJS = $(MODULE_CPPOBJS))
#$(info MODULE_ASMOBJS = $(MODULE_ASMOBJS))

$(MODULE_OBJS): MODULE_OPTFLAGS:=$(MODULE_OPTFLAGS)
$(MODULE_OBJS): MODULE_COMPILEFLAGS:=$(MODULE_COMPILEFLAGS) 
$(MODULE_OBJS): MODULE_CFLAGS:=$(MODULE_CFLAGS)
$(MODULE_OBJS): MODULE_CPPFLAGS:=$(MODULE_CPPFLAGS)
$(MODULE_OBJS): MODULE_ASMFLAGS:=$(MODULE_ASMFLAGS)
$(MODULE_OBJS): MODULE_SRCDEPS:=$(MODULE_SRCDEPS)
$(MODULE_OBJS): MODULE_INCLUDES:=$(MODULE_INCLUDES)

COMPILEFLAGS = $(GLOBAL_COMPILEFLAGS) $(KERNEL_COMPILEFLAGS)

$(MODULE_COBJS): $(BUILDDIR)/%.o: %.c $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_CFLAGS) $(ARCH_CFLAGS) $(MODULE_CFLAGS) $(THUMBCFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

$(MODULE_CPPOBJS): $(BUILDDIR)/%.o: %.cpp $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_CPPFLAGS) $(ARCH_CPPFLAGS) $(MODULE_CPPFLAGS) $(THUMBCFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

$(MODULE_ASMOBJS): $(BUILDDIR)/%.o: %.S $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_ASMFLAGS) $(ARCH_ASMFLAGS) $(MODULE_ASMFLAGS) $(THUMBCFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

# overridden arm versions
$(MODULE_ARM_COBJS): $(BUILDDIR)/%.o: %.c $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_CFLAGS) $(ARCH_CFLAGS) $(MODULE_CFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

$(MODULE_ARM_CPPOBJS): $(BUILDDIR)/%.o: %.cpp $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_CPPFLAGS) $(ARCH_CPPFLAGS) $(MODULE_CPPFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

$(MODULE_ARM_ASMOBJS): $(BUILDDIR)/%.o: %.S $(MODULE_SRCDEPS)
	@$(MKDIR)
	@echo compiling $<
	$(NOECHO)$(CC) $(GLOBAL_OPTFLAGS) $(MODULE_OPTFLAGS) $(COMPILEFLAGS) $(ARCH_COMPILEFLAGS) $(MODULE_COMPILEFLAGS) $(GLOBAL_ASMFLAGS) $(ARCH_ASMFLAGS) $(MODULE_ASMFLAGS) $(GLOBAL_INCLUDES) $(MODULE_INCLUDES) -c $< -MD -MP -MT $@ -MF $(@:%o=%d) -o $@

# clear some variables we set here
MODULE_CSRCS :=
MODULE_CPPSRCS :=
MODULE_ASMSRCS :=
MODULE_COBJS :=
MODULE_CPPOBJS :=
MODULE_ASMOBJS :=

# MODULE_OBJS is passed back
#MODULE_OBJS :=

