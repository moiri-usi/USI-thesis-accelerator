#include <fstream>
#include <algorithm>
#include <string>
#include <iostream>
#include <cctype>

using namespace std;

#define COMMENT_LINE_CNT 5

void write_coe(const char *instr, const char *outstr, string op_zero);

int main(int argc, char *argv[]) {

    write_coe("pi_bin_scale.mat", "pi_scale.coe", "0000000000000000000000000");
    write_coe("b_bin_scale.mat", "b_scale.coe", "000000000000000000");
    write_coe("tp_bin_scale.mat", "tp_scale.coe", "000000000000000000");

    return 0;
}

void write_coe(const char *instr, const char *outstr, string op_zero) {
    std::ifstream infile;
    std::ofstream outfile;
    remove(outstr);
    outfile.open (outstr, std::ofstream::out);
    infile.open (instr, std::ofstream::in);
    outfile << "memory_initialization_radix = 2;" << endl;
    outfile << "memory_initialization_vector =" << endl;
    outfile << op_zero << "," << endl;

    string line;
    int i = 1;
    if (infile.is_open())
    {
        while ( getline (infile, line) )
        {
            if (i > COMMENT_LINE_CNT){
                line.erase(remove_if(line.begin(), line.end(), ::isspace), line.end());
                outfile << line << "," << endl;
            }
            i++;
        }
    }
    outfile.close();
    infile.close();
}
