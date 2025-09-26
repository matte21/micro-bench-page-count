#include <stdio.h>
#include <time.h>
#include <stdlib.h>

struct page {
    struct page *next;
};

int main(int argc, char* argv[]) {
    int nbr_pages = atoi(argv[1]);

    struct timespec start_time, end_time;
    double elapsed_time;

    // Init the list.
    struct page *head;
    struct page *prev;
    for (int i = 0; i < nbr_pages; i++) {
        if (prev == NULL) {
            head = (struct page*) malloc(sizeof(struct page*));
            prev = head;
        } else {
            prev->next = (struct page*) malloc(sizeof(struct page*));
            prev = prev->next;
        }
    }

    struct page *cursor = head;
    int counter = 1;
    clock_gettime(CLOCK_MONOTONIC_RAW, &start_time);

    // Your C code to be benchmarked goes here.
    while (cursor->next != NULL) {
        cursor = cursor->next;
        counter++;
    }

    clock_gettime(CLOCK_MONOTONIC_RAW, &end_time);

    elapsed_time = (double)(end_time.tv_sec - start_time.tv_sec) +
                   (double)(end_time.tv_nsec - start_time.tv_nsec) / 1e9;
    printf("Elapsed time: %f seconds\n", elapsed_time);
    printf("Nbr pages: %d\n", counter);
}
