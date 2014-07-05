#include <fstream>
#include <algorithm>
#include <string>
#include <iostream>
#include <cctype>

using namespace std;

#define COMMENT_LINE_CNT 5
#define OP1 25
#define OP2 25

void write_coe(const char *instr, const char *outstr, string op_zero);

int main(int argc, char *argv[]) {
    int i;
    char init_op1[OP1+1];
    char init_op2[OP2+1];
    for (i=0; i<OP1; i++)
        init_op1[i] = '0';
    for (i=0; i<OP2; i++)
        init_op2[i] = '0';
    write_coe("pi_bin.mat", "pi.coe", init_op1);
    write_coe("b_bin.mat", "b.coe", init_op2);
    write_coe("tp_bin.mat", "tp.coe", init_op2);

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
