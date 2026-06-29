#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUM_ITERATIONS 10000

void run_test(size_t size) {
    void* pointers[NUM_ITERATIONS];
    struct timespec start, end;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        pointers[i] = malloc(size);
        if (pointers[i] == NULL) {
            fprintf(stderr, "malloc failed for size %zu\n", size);
            return;
        }
        free(pointers[i]);
    }
    clock_gettime(CLOCK_MONOTONIC, &end);

    long long total_nanoseconds = (end.tv_sec - start.tv_sec) * 1000000000LL + (end.tv_nsec - start.tv_nsec);
    double avg_time_ns = (double)total_nanoseconds / NUM_ITERATIONS;
    printf("%zu,%.2f\n", size, avg_time_ns);
}

int main() {
    printf("size_bytes,avg_time_ns\n");
    for (size_t size = 16; size <= 1024; size += 16) {
        run_test(size);
    }

    double current_size = 1024.0;
    while (current_size <= 8 * 1024 * 1024) {
        size_t size = (size_t)current_size;
        run_test(size);

        current_size *= 1.05;
        if ((size_t)current_size <= size) {
            current_size = size + 1;
        }
    }
    return 0;
}
