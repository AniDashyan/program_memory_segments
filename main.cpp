#include <iostream>

int global_var_initialized = 42;   // Segment
int global_var_uninitialized;      // Segment
const char* msg = "Hello";         // Segment

void func() { }                    // Segment

int main() {
    int local_var = 10;            // Segment
    int* heap_var = new int(20);   // Segment

    std::cout << msg << std::endl;
    delete heap_var;
}