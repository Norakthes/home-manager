#ifndef NVIDIA_TEMP_H
#define NVIDIA_TEMP_H

// Function to initialize NVIDIA monitoring
int nvidia_init(void);

// Function to cleanup NVIDIA monitoring
void nvidia_cleanup(void);

// Function to get temperature as a string (caller must free)
char* nvidia_get_temp(void);

#endif
