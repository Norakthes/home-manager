#include "nvidia_temp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// NVIDIA ML declarations
typedef struct nvmlDevice_st* nvmlDevice_t;
typedef int nvmlReturn_t;
#define NVML_SUCCESS 0
#define NVML_TEMPERATURE_GPU 0

// Declare NVML functions
nvmlReturn_t nvmlInit(void);
nvmlReturn_t nvmlShutdown(void);
nvmlReturn_t nvmlDeviceGetHandleByIndex(unsigned int index, nvmlDevice_t *device);
nvmlReturn_t nvmlDeviceGetTemperature(nvmlDevice_t device, unsigned int type, unsigned int *temp);
const char* nvmlErrorString(nvmlReturn_t result);

static nvmlDevice_t device = NULL;

int nvidia_init(void) {
    nvmlReturn_t result = nvmlInit();
    if (result != NVML_SUCCESS) {
        return 0;
    }

    result = nvmlDeviceGetHandleByIndex(0, &device);
    if (result != NVML_SUCCESS) {
        nvmlShutdown();
        return 0;
    }

    return 1;
}

void nvidia_cleanup(void) {
    if (device != NULL) {
        nvmlShutdown();
        device = NULL;
    }
}

char* nvidia_get_temp(void) {
    unsigned int temp;
    char *result;
    
    if (device == NULL) {
        return strdup("N/A");
    }

    nvmlReturn_t ret = nvmlDeviceGetTemperature(device, NVML_TEMPERATURE_GPU, &temp);
    if (ret != NVML_SUCCESS) {
        return strdup("ERR");
    }

    result = malloc(8);  // Enough for "XXX" + null terminator
    if (result == NULL) {
        return strdup("ERR");
    }

    snprintf(result, 8, "%u", temp);
    return result;
}
