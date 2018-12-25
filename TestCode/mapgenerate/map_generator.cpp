#include <iostream>
#include <string>
using namespace std;

int main(void)
{
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
            } else {
                mt[i][j] = 3;
            }
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            cout << "mt[" << i << "][" << j << "] = ";
            if (mt[i][j] == 0) {
                cout << "3'b000;\n";
            } else if (mt[i][j] == 1) {
                cout << "3'b001;\n";
            } else if (mt[i][j] == 2) {
                cout << "3'b010;\n";
            } else {
                cout << "3'b011;\n";
            }
        }
        cout << '\n';
    }

    return 0;
}