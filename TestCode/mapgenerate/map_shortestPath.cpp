#include <bits/stdc++.h>
using namespace std;

#define endl '\n'
using P = pair<int, int>;
#define r first
#define c second

const int N = 30;
const int INF = 99;
const char WALL = '#';
const char ROAD = '.';

// down, up, right, left
const int dr[] = {1, -1, 0, 0};
const int dc[] = {0, 0, 1, -1};

int R, C;
int player_r, player_c;
char mp[N][N];
char dir[N][N];
int dist[N][N];

void init();
void process();
void print();
void print_verilog();

int main()
{
	ios::sync_with_stdio(false); cin.tie(0);
	init();
	process();
	print();
	print_verilog();
	cout.flush();
	return 0;
}

void init()
{
	cin >> R >> C;
	cin >> player_r >> player_c;
	char ch;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			cin >> ch;
			mp[r][c] = (ch == '*'? WALL : ROAD);
		}
}

void process() // with bellman ford
{
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
			if(mp[r][c] == WALL) dir[r][c] = 'x', dist[r][c] = INF;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			dist[r][c] = INF;
		}
	dist[player_r][player_c] = 0;
	for(int turn = 0; turn < R*C; turn++)
	{
		for(int r = 0; r < R; r++)
			for(int c = 0; c < C; c++)
			{
				if(dir[r][c] == 'x') continue;
				int tmp = dist[r][c];
				for(int d = 0; d < 4; d++)
				{
					int nr = r+dr[d], nc = c+dc[d];
					if(dist[nr][nc] + 1 < tmp) 
					{
						tmp = dist[nr][nc]+1;
						if(d == 0) dir[r][c] = 'd';
						else if(d == 1) dir[r][c] = 'u';
						else if(d == 2) dir[r][c] = 'r';
						else dir[r][c] = 'l';
					}
				}
				dist[r][c] = tmp;
			}
	}
}

/*
void process()
{
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
			if(mp[r][c] == WALL) dir[r][c] = 'x', dist[r][c] = INF;
	queue<P> q;
	q.emplace(player_r, player_c);
	dir[player_r][player_c] = 'u';
	dist[player_r][player_c] = 0;
	while(!q.empty())
	{
		int r = q.front().r, c = q.front().c;
		q.pop();
		for(int d = 0; d < 4; d++)
		{
			int nr = r+dr[d], nc = c+dc[d];
			if(dir[nr][nc] == 0)
			{
				q.emplace(nr, nc);
				if(d == 0) dir[nr][nc] = 'u';
				else if(d == 1) dir[nr][nc] = 'd';
				else if(d == 2) dir[nr][nc] = 'l';
				else dir[nr][nc] = 'r';
				dist[nr][nc] = dist[r][c] + 1;
			}
		}
	}
}
*/

void print()
{
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
			cout << dir[r][c] << " ";
		cout << endl;
	}
	
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
			cout << setw(2) << dist[r][c] << " ";
		cout << endl;
	}
}

void print_verilog()
{
	ofstream fout("verilogCode.v");
	
	// init_backtrack_map01
	fout << "task init_backtrack_map01;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
		{
			string dirStr;
			if(dir[r][c] == 'x') dirStr = "`MOVE_STOP";
			else if(dir[r][c] == 'u') dirStr = "`MOVE_UP";
			else if(dir[r][c] == 'd') dirStr = "`MOVE_DOWN";
			else if(dir[r][c] == 'l') dirStr = "`MOVE_LEFT";
			else dirStr = "`MOVE_RIGHT";
			
			fout << "nxt_backtrack[" << r << "][" << c << "] <= " << dirStr << ";" << endl;
		}
	}
	fout << "end" << endl;
	fout << "endtask" << endl;

/*	
	// init_shortest_dist_map01
	fout << "task init_shortest_dist_map01;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
		{
			fout << "shortest_dist[" << r << "][" << c << "] <= ";
			fout << dist[r][c] << ";" << endl;
		}
	}
	fout << "end" << endl;
	fout << "endtask" << endl;

	// relax_backtrack_map01
	fout << "task relax_backtrack_map01;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
		{
			if(dir[r][c] == 'x')
			{
				fout << "nxt_backtrack[" << r << "][" << c << "] <= ";
				fout << "backtrack[" << r << "][" << c << "];" << endl;
				continue;
			}
			fout << "nxt_backtrack[" << r << "][" << c << "] <= ";
			fout << "relax_dir(";
			fout << r-1 << "," << c << ",";
			fout << r+1 << "," << c << ",";
			fout << r << "," << c-1 << ",";
			fout << r << "," << c+1 << ",";
			fout << "shortest_dist[" << r << "][" << c << "],";
			fout << "backtrack[" << r << "][" << c << "]";
			fout << ");" << endl;
		}
	}
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// relax_shortest_dist_map01
	fout << "task relax_shortest_dist_map01;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
	{
		for(int c = 0; c < C; c++)
		{
			if(dir[r][c] == 'x')
			{
				fout << "nxt_shortest_dist[" << r << "][" << c << "] <= ";
				fout << "shortest_dist[" << r << "][" << c << "];" << endl;
				continue;
			}
			fout << "nxt_shortest_dist[" << r << "][" << c << "] <= ";
			fout << "relax_dist(";
			fout << r-1 << "," << c << ",";
			fout << r+1 << "," << c << ",";
			fout << r << "," << c-1 << ",";
			fout << r << "," << c+1 << ",";
			fout << "shortest_dist[" << r << "][" << c << "]";
			fout << ");" << endl;
		}
	}
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// shift backtrack
	fout << "task shift_backtrack;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			fout << "backtrack[" << r << "][" << c << "] <= ";
			fout << "nxt_backtrack[" << r << "][" << c << "];" << endl;
		}
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// shift shortest_path
	fout << "task shift_shortest_dist;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			fout << "shortest_dist[" << r << "][" << c << "] <= ";
			fout << "nxt_shortest_dist[" << r << "][" << c << "];" << endl;
		}
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// shift nxt_backtrack
	fout << "task shift_nxt_backtrack;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			fout << "nxt_backtrack[" << r << "][" << c << "] <= ";
			fout << "backtrack[" << r << "][" << c << "];" << endl;
		}
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// shift nxt_backtrack
	fout << "task shift_nxt_shortest_dist;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			fout << "nxt_shortest_dist[" << r << "][" << c << "] <= ";
			fout << "shortest_dist[" << r << "][" << c << "];" << endl;
		}	
	fout << "end" << endl;
	fout << "endtask" << endl;
	
	// bf_init_shortest_path
	fout << "task bf_init_shortest_path;" << endl;
	fout << "begin" << endl;
	for(int r = 0; r < R; r++)
		for(int c = 0; c < C; c++)
		{
			fout << "nxt_shortest_dist[" << r << "][" << c << "] <= ";
			fout << 1023 << ";" << endl;
		}
	fout << "nxt_shortest_dist[player_r][player_c] <= 0;" << endl;
	fout << "end" << endl;
	fout << "endtask" << endl;
*/
}

/*
10 20
3 3
********************
*...***.**.........*
*.*.***....***.***.*
*.*....*.*******...*
*.*.*.**.****....***
*****.........**...*
*.*....*.****.****.*
*.*.**.*..**.....*.*
*...**.**....***...*
********************


10 20 
2 14
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
