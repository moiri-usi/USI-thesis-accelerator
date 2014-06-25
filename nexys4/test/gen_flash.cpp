#include <fstream>
#include <iomanip>

using namespace std;

#define N_CNT 100

int main(int argc, char *argv[]) {
    std::ofstream mem;

    remove("data.mem");
    mem.open ("data.mem", std::ofstream::out);

    mem << "@000000" << endl;
    for (int i=0; i<N_CNT; i++)
        mem << setw(2) << setfill('0') << hex << i << " ";

    mem.close();

    return 0;
}
