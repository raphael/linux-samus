snd-soc-sst-haswell-pcm-objs := \
	sst-haswell-ipc.o sst-haswell-pcm.o sst-haswell-dsp.o
ifdef CONFIG_DEBUG_FS
	snd-soc-sst-haswell-pcm-objs += ../common/sst-debugfs.o
endif

obj-$(CONFIG_SND_SOC_INTEL_HASWELL) += snd-soc-sst-haswell-pcm.o
