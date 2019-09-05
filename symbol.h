#include<bits/stdc++.h>
using namespace std;
int lineno=1;
struct symTab{
    string name ;
    int type ;
    int eletype;
    vector<int> dim ;
    int tag;
    int level;
};

struct Node{
    int type;
    int reg;
    string id;
    vector<int> namelist;
    vector<string> idlist;
    vector<int> eletypelist;

    int value;
    float val;
    vector<int>nextlist;
    int next;
    int quad;
    vector<int>falselist;
    vector< pair<string,int> >comp;
    int begin;
    int end;
    vector<string> list;
    int flag;

    vector<int> dim;
    vector<string> iddim;
    int type2;

    vector<int> nextlist2;
    vector<int> regNum;

    vector<int> regFunc;

    int sem_type;
};

struct funcNameTable{
    string name;
    int resultType;
    vector<symTab> parList;
    vector<symTab> varList;
    int numParam;
    
};
