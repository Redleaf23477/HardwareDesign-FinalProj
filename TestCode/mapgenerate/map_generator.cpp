#include <bits/stdc++.h>
using namespace std;

int main(void)
{
	ofstream fout("map.v");
    int n, m;
    cout << "generate n x m map ?\n";
    cout << "n : \n";
    cin >> n ;
    cout << "m : \n";
    cin >> m;

    cout << "please cin fake map\n";
    string s;
    int mt[n][m];
    for (int i = 0; i < n; i++) {
        cin >> s;
        for (int j = 0; j < m; j++) {
            if (s[j] == '-') {
                mt[i][j] = 0;
            } else if (s[j] == '=') {
                mt[i][j] = 1;
            } else if (s[j] == '*') {
                mt[i][j] = 2;
            } else if (s[j] == '#'){
                mt[i][j] = 3;
            } else {
                mt[i][j] = 4;
            }
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            fout << "mt[" << i << "][" << j << "] = ";
            if (mt[i][j] == 0) {
                fout << "3'b000;\n";
            } else if (mt[i][j] == 1) {
                fout << "3'b001;\n";
            } else if (mt[i][j] == 2) {
                fout << "3'b010;\n";
            } else if (mt[i][j] == 3) {
                fout << "3'b011;\n";
            } else {
                fout << "3'b100;\n";
            }
        }
        fout << '\n';
    }

    return 0;
}

/*
10 20
********************
*-=-*=--*--==---==-*
*-*=--****-***=-****
****--=--*-*=====--*
*-=*=*-*--=*=***=*-*
*-**--=*=*--=====***
*=---*-=-*-**-****-*
*=****=*=--*---*--=*
*--=*--*-*-=-*-=-*-*
********************
*/
